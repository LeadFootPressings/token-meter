# Architecture and privacy

## What the code does

This is an accessory macOS application with no Dock window. `Source/main.swift` builds a SwiftUI meter/settings interface hosted in two AppKit `NSPanel` windows. An `NSStatusItem` supplies the menu-bar menu. `NSWorkspace` notifications track supported desktop hosts, activation, sleep, and wake. A timer polls every 180 seconds while monitoring is active.

The window controller retains the previous implementation's click/drag behavior, window levels, host lifecycle, position fallback, and menu commands. `MeterState` publishes UI data. The reader runs on a background queue; the result returns to the main queue. A generation counter prevents a completed read from being applied to a different host lifecycle.

`Source/Usage.swift` contains numeric validation, bucket/window selection, executable discovery, and a bounded stdio client. It is the only extraction from the original single-file app, enabling offline transport tests without starting AppKit. No framework migration was introduced.

```text
macOS host-app notifications → AppDelegate → three-minute/manual refresh
                                              ↓ background queue
installed Codex executable ← stdio → UsageReader → Snapshot → MeterState → SwiftUI
         ↓
  Codex-managed credentials/configuration/network services
```

The reader discovers fixed, conventional executable locations, never searches a shell's PATH or runs command strings. Arguments are passed directly to `Process`. It performs `initialize`, `initialized`, and `account/rateLimits/read` in sequence. The selected bucket must be `codex`; the two windows are identified by duration, independent of response order. A partial result shows the known window and leaves the missing one unavailable. A result with neither supported window becomes an error.

## Data inventory

| Data | Token Meter behavior |
| --- | --- |
| Credentials, login tokens, API keys | Does not read files containing them or receive them through its UI; child Codex handles its existing sign-in |
| Allowance percentages and reset times | In-memory display; retained as last-known after errors; not persisted |
| Window position / placement | macOS UserDefaults, provisional bundle domain `local.tokenmeter.app` |
| Prompts, chats, usage histories, billing | No requests for these data and no parsing of session history |
| Diagnostic output | Generic errors and test labels; the connection check reports availability without percentages |
| Screenshots | Generated only on request in demo mode, using synthetic values |
| Network | None implemented directly in Token Meter; the installed Codex process may communicate with OpenAI according to its configuration |

No account settings, authentication files, remote MCP connections, or system security settings are changed by preparation. The app has no updater, telemetry library, inbound listener, or server backend. The optional installer can create a LaunchAgent only when explicitly invoked with `--login`.

## Trust boundary and tradeoffs

The app is not an App Sandbox application. Its child executable runs with the current user's privileges, inherits the environment, and uses the user's home directory as its working directory. Fixed-path selection reduces accidental executable substitution but does not validate the executable's publisher or version. An attacker already able to replace the installed executable can execute code under this user. Codex may load its own user configuration and produce its own logs; claims about Token Meter's lack of logs do not extend to Codex.

The protocol permits much more than Token Meter requests. No model or thread operation is sent here, but the child is not an operating-system-enforced read-only service. The mock validates the emitted request sequence. Future changes to the integration require a renewed review.

The reader uses a monotonic 20-second deadline, a two-megabyte total-response cap, generic error messages, and a short termination grace period followed by forced termination of its own child if necessary. It does not kill other Codex processes. A pending read may finish after the desktop host quits; no new periodic reads start while inactive.

A long-lived server could reduce repeated process startup, but it broadens lifecycle complexity. Retaining short-lived reads is the conservative initial choice. Polling is not proof of source-data freshness.

## Compatibility and commercial boundary

The app-server documentation describes the rate-limit method and warns that this authentication path is not permitted for commercial or hosted services. A future paid Token Meter or hosted version needs a separately reviewed, permitted integration; changing the source license does not change service terms. See the [official app-server documentation](https://learn.chatgpt.com/docs/app-server).

The local candidate does not embed or redistribute Codex. Apple frameworks are system dependencies. Python is build/test tooling only. No package lockfile is needed because there are no third-party library dependencies. The icon generator uses AppKit primitives; the menu-bar glyph is a system SF Symbol at runtime.
