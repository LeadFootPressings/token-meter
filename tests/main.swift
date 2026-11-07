import Foundation
var checks = 0
func check(_ value: @autoclosure () -> Bool, _ label: String) {
    checks += 1
    guard value() else { fputs("FAIL: \(label)\n", stderr); exit(1) }
    print("PASS: \(label)")
}
func allowance(_ used: Any, _ minutes: Any = 300, _ reset: Any = 1_800_000_000) -> Allowance? {
    Allowance.parse(["usedPercent":used,"windowDurationMins":minutes,"resetsAt":reset])
}
check(allowance(12)?.remaining == 88, "integer JSON number")
check(allowance(12.6)?.remaining == 87, "fraction rounds consistently")
check(allowance(1e300)?.remaining == 0, "huge finite percentage cannot overflow")
check(allowance(-1e300)?.remaining == 100, "negative huge percentage clamps")
check(allowance(Double.infinity) == nil, "infinite percentage rejected")
check(allowance(Double.nan) == nil, "NaN percentage rejected")
check(allowance(true) == nil, "boolean percentage rejected")
check(allowance("12") == nil, "string percentage rejected")
check(allowance(5, true) == nil, "boolean duration rejected")
check(allowance(5, 300.5) == nil, "fractional duration rejected")
check(allowance(5, 1e300) == nil, "huge duration rejected")
check(allowance(5, -300) == nil, "negative duration rejected")
check(allowance(5, 300, Double.infinity)?.reset == nil, "infinite reset unavailable")
check(allowance(5, 300, 1e300)?.reset == nil, "huge reset unavailable")
check(allowance(5, 300, true)?.reset == nil, "boolean reset unavailable")
check(Allowance.parse(["windowDurationMins":300]) == nil, "missing usage unavailable")
let w: [String:Any] = ["usedPercent":59,"windowDurationMins":10080]
let s: [String:Any] = ["usedPercent":28,"windowDurationMins":300]
let reversed = Snapshot.parse(["rateLimitsByLimitId":["codex":["primary":w,"secondary":s]]])
check(reversed?.short?.remaining == 72 && reversed?.week?.remaining == 41, "windows identified by duration")
check(Snapshot.parse(["rateLimits":["limitId":"codex","primary":s]])?.short?.remaining == 72, "legacy codex bucket accepted")
check(Snapshot.parse(["rateLimits":["limitId":"other","primary":s]]) == nil, "unrelated bucket rejected")
check(Snapshot.parse(["rateLimitsByLimitId":["codex":[:]]]) == nil, "empty bucket is an error")
let partial = Snapshot.parse(["rateLimitsByLimitId":["codex":["secondary":w]]])
check(partial?.short == nil && partial?.week?.remaining == 41, "partial window remains unavailable")
let python = CommandLine.arguments[1], fixture = CommandLine.arguments[2]
for mode in ["success", "fragmented", "closed", "stalled", "init-error", "error", "oversized", "malformed", "unsupported"] {
    let start = ProcessInfo.processInfo.systemUptime
    let result = UsageReader.read(executablePath: python, arguments: [fixture, mode], timeout: 0.7)
    switch result {
    case .success(let value):
        check(["success","fragmented"].contains(mode) && value.short?.remaining == 72 && value.week?.remaining == 41, "transport \(mode)")
    case .failure(let error):
        check(!["success","fragmented"].contains(mode), "transport \(mode)")
        check(!error.localizedDescription.contains("SYNTHETIC_PRIVATE_ERROR"), "raw service error withheld: \(mode)")
    }
    check(ProcessInfo.processInfo.systemUptime - start < 2.5, "bounded completion: \(mode)")
}
if case .failure = UsageReader.read(executablePath:nil) { check(true,"missing executable") } else { check(false,"missing executable") }
if case .failure = UsageReader.read(executablePath:"/does-not-exist") { check(true,"unlaunchable executable") } else { check(false,"unlaunchable executable") }
print("PASS: \(checks) offline checks; no production account used")
