# Validation and reproducibility

Validation date: November 5, 2026. Host: Apple silicon, macOS 27.0.1, Apple Swift 6.4.2, Swift 5 language mode. No paid generation calls or production account queries were made during this preparation.

## Automated checks performed

| Check | Result | Scope |
| --- | --- | --- |
| Native ARM64 app build | Passed | Explicit macOS 13 compiler target, local icon generation, ad-hoc signature verification |
| Offline core suite | 48 checks passed | Numeric bounds/types, correct window mapping, legacy/partial/missing buckets, synthetic stdio peers |
| Retained app parser checks | 6 passed | Basic percentage and bucket regressions |
| Native lifecycle suite | 18 checks passed | Shared levels, host stop/start paths, panel visibility, desktop collapse/reopen |
| Native click/drag/position suite | 14 checks passed | Click toggle, successive synthetic pointer events, saved position, offscreen fallback, reset persistence |
| Clean-directory build | Passed | Source copied without cache, app output, Git metadata, or Codex credentials; rebuilt and reran offline tests |
| Copy-only installation | Passed | Separate temporary destination; copied signature verified; duplicate install refused |
| ZIP/checksum | Passed | App-only package, local signature, ARM64 identity; no external binary/dependency bundled |
| Source/history heuristic scan | Passed | No matched secret formats or personal paths; zero historical blobs available |
| Exhibition | Passed | Local HTML assets/anchors/alt text/JSON; desktop and 390px viewport; keyboard slider; low/offline examples; no browser console warnings/errors observed |

The first AppKit run in the restricted shell aborted with `EXC_CRASH / SIGABRT (Abort trap: 6)`. The same offline native tests passed when run with access to the macOS graphical session. This was not treated as proof that a build alone was sufficient.

## Real UI checks performed

In the actual demo application, native accessibility interactions selected **On desktop**, verified settings collapsed, reopened settings by clicking the meter, selected **Always on top**, and invoked **Refresh**. Screenshot rendering used actual SwiftUI/AppKit views with synthetic 72% and 41% allowances, never a production account. The settings preview was visually inspected and given the same window background in the view to avoid a transparent/illegible export.

A coordinate-drag attempt through the UI automation tool returned `noWindowsAvailable` for the borderless panel. Therefore physical-pointer dragging is not claimed as verified in this run. The existing drag implementation was preserved and all 14 synthetic native event/position regressions passed. A manual physical drag on a target Mac remains on the acceptance checklist.

Lifecycle tests exercise real controller/window methods while suppressing reads; they do not quit the user's active ChatGPT/Codex app. Native UI tests and demo mode use isolated preference domains and remove them on normal termination. They do not migrate or reset the installed predecessor's settings.

## Commands

```sh
./build.sh
./scripts/test.sh
./scripts/test.sh --ui
python3 scripts/audit.py
./scripts/package.sh
```

`tests/fixtures/server.py` is a synthetic peer, not a Codex wrapper. It validates the outgoing sequence and supplies success, fragmented data, initialization failure, raw service failure, malformed/oversized responses, unsupported windows, closed pipes, and a process that ignores SIGTERM. Every test has an elapsed-time bound. No fixture opens a network connection or reads a credential file.

## Explicitly unverified

- Current production account/service compatibility, sign-in recovery, upstream freshness, and the supported installed Codex version range.
- Real host-app quit/relaunch, full sleep/wake, display disconnects, Spaces/full-screen, and VoiceOver acceptance on the final release.
- macOS 13 runtime behavior and Intel hardware. The minimum target is a build claim, not a tested support matrix.
- Login LaunchAgent registration in the user's account; it was not changed or exercised against the real login environment.
- Developer ID signing, notarization, fresh-machine/quarantined-download acceptance, and hosted GitHub Actions.
- Byte-for-byte reproducibility across compilers/machines. The clean-directory build proves inputs are self-contained in this environment, not deterministic binaries everywhere.

The local original project and installed 1.0.6 binary were hash-checked after preparation and remained unchanged. Detailed machine-local evidence lives in the ignored preparation folder and should not be published without review.

## Subsequent website and MIT revision

The owner selected LeadFoot Pressings and approved MIT with LeadFoot as the copyright holder. The native application source files are byte-for-byte unchanged from the pre-redesign checkpoint. The build now includes LICENSE.txt in the app's Resources directory before signing. The updated build, six retained parser checks, signature verification, package contents, and exact bundled license were checked. Earlier core/lifecycle/drag evidence remains the prior validation of the unchanged application source; those suites were not rerun for a website styling change.

The revised static site was visually inspected at 1280px desktop and 390px mobile widths. Both actual app images loaded; no horizontal overflow was observed. Low/offline presets, keyboard adjustment, and the mobile controls worked; no console warnings/errors were observed. HTML asset/anchor/alt-text and JSON checks passed. Translucent surfaces have opaque fallbacks, reduced-transparency rules, visible focus indicators, and reduced-motion handling. A full assistive-technology audit is not claimed.
