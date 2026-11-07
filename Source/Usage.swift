import Foundation
import CoreFoundation
import Darwin

struct Allowance: Equatable {
    let remaining: Int
    let reset: Date?
    let minutes: Int

    static func number(_ value: Any?) -> Double? {
        guard let n = value as? NSNumber, CFGetTypeID(n) != CFBooleanGetTypeID(), n.doubleValue.isFinite else { return nil }
        return n.doubleValue
    }

    static func parse(_ value: Any?) -> Allowance? {
        guard let d = value as? [String: Any], let used = number(d["usedPercent"]),
              let duration = number(d["windowDurationMins"]), duration > 0,
              duration <= 525_600, duration.rounded() == duration else { return nil }
        // Clamp before converting to Int: a finite Double can still overflow Int.
        let remaining = Int((100 - min(100, max(0, used))).rounded())
        let reset = number(d["resetsAt"]).flatMap { seconds -> Date? in
            guard (0...253_402_300_799).contains(seconds) else { return nil }
            return Date(timeIntervalSince1970: seconds)
        }
        return Allowance(remaining: remaining, reset: reset, minutes: Int(duration))
    }
}

struct Snapshot {
    let short: Allowance?
    let week: Allowance?
    static func parse(_ result: [String: Any]) -> Snapshot? {
        let buckets = result["rateLimitsByLimitId"] as? [String: Any]
        let legacy = result["rateLimits"] as? [String: Any]
        guard let bucket = buckets?["codex"] as? [String: Any] ?? (legacy?["limitId"] as? String == "codex" ? legacy : nil) else { return nil }
        let windows = [Allowance.parse(bucket["primary"]), Allowance.parse(bucket["secondary"])].compactMap { $0 }
        let short = windows.first { $0.minutes == 300 }, week = windows.first { $0.minutes == 10080 }
        guard short != nil || week != nil else { return nil }
        return Snapshot(short: short, week: week)
    }
}

// A short-lived local stdio client. No model turns, login, or mutation requests.
final class UsageReader {
    static var executable: String? {
        let applications = ["/Applications", FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications").path]
        let suffixes = ["ChatGPT.app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex",
                        "Codex.app/Contents/Resources/codex",
                        "Codex.app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex"]
        let candidates = applications.flatMap { base in suffixes.map { base + "/" + $0 } } + ["/opt/homebrew/bin/codex", "/usr/local/bin/codex"]
        return candidates.first { FileManager.default.isExecutableFile(atPath: $0) }
    }

    // Explicit injection is used only by compiled tests; no environment/PATH override.
    static func read(executablePath: String? = executable, arguments: [String] = ["app-server"], timeout: TimeInterval = 20) -> Result<Snapshot, Error> {
        func connectionError(_ text: String) -> NSError { NSError(domain: "TokenMeter", code: 1, userInfo: [NSLocalizedDescriptionKey: text]) }
        guard let path = executablePath else { return .failure(connectionError("Codex connection unavailable. Open or update the ChatGPT/Codex app.")) }
        let process = Process(), input = Pipe(), output = Pipe()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        process.standardInput = input; process.standardOutput = output; process.standardError = FileHandle.nullDevice
        process.currentDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
        do { try process.run() } catch { return .failure(connectionError("Could not start the installed Codex executable.")) }
        // Foundation owns the pipe objects; close the parent's duplicate ends.
        try? output.fileHandleForWriting.close()
        try? input.fileHandleForReading.close()
        defer {
            try? input.fileHandleForWriting.close()
            try? output.fileHandleForReading.close()
            if process.isRunning { process.terminate() }
            let grace = ProcessInfo.processInfo.systemUptime + 0.25
            while process.isRunning && ProcessInfo.processInfo.systemUptime < grace { Thread.sleep(forTimeInterval: 0.01) }
            if process.isRunning { kill(process.processIdentifier, SIGKILL) }
            process.waitUntilExit()
        }
        // Avoid SIGPIPE terminating the app if the child closes stdin early.
        _ = fcntl(input.fileHandleForWriting.fileDescriptor, F_SETNOSIGPIPE, 1)
        func send(_ message: [String: Any]) throws {
            var data = try JSONSerialization.data(withJSONObject: message); data.append(10)
            try input.fileHandleForWriting.write(contentsOf: data)
        }
        let deadline = ProcessInfo.processInfo.systemUptime + max(0.05, timeout)
        do {
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "development"
            try send(["id": 1, "method": "initialize", "params": ["clientInfo": ["name": "token_meter", "title": "Token Meter", "version": version]]])
            var buffer = Data(), initialized = false, received = 0
            let fd = output.fileHandleForReading.fileDescriptor
            var bytes = [UInt8](repeating: 0, count: 8192)
            while ProcessInfo.processInfo.systemUptime < deadline {
                var descriptor = pollfd(fd: fd, events: Int16(POLLIN), revents: 0)
                let ready = poll(&descriptor, 1, 100)
                if ready < 0 { if errno == EINTR { continue }; break }
                if ready == 0 { continue }
                let count = Darwin.read(fd, &bytes, bytes.count)
                if count <= 0 { break }
                received += count
                guard received <= 2_000_000 else { return .failure(connectionError("Codex response exceeded the safety limit.")) }
                buffer.append(contentsOf: bytes.prefix(count))
                while let newline = buffer.firstIndex(of: 10) {
                    let line = Data(buffer[..<newline]); buffer.removeSubrange(...newline)
                    guard let message = try? JSONSerialization.jsonObject(with: line) as? [String: Any] else { continue }
                    if message["id"] as? Int == 1 && !initialized {
                        guard message["error"] == nil, message["result"] != nil else { return .failure(connectionError("Could not initialize Codex connection.")) }
                        try send(["method": "initialized", "params": [:]])
                        try send(["id": 2, "method": "account/rateLimits/read"])
                        initialized = true
                    } else if message["id"] as? Int == 2 && initialized {
                        guard message["error"] == nil, let result = message["result"] as? [String: Any], let snapshot = Snapshot.parse(result) else {
                            return .failure(connectionError("Usage unavailable. Sign in to Codex, then refresh."))
                        }
                        return .success(snapshot)
                    }
                }
            }
            return .failure(connectionError("Connection timed out or closed. Will retry automatically."))
        } catch { return .failure(connectionError("Codex connection closed unexpectedly. Will retry automatically.")) }
    }
}
