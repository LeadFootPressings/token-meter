# Roadmap

## Essential before public release

1. MIT licensing and the LeadFoot copyright notice are approved and applied. Confirm the public repository/account identity, contribution workflow, and provisional app bundle identifier.
2. Confirm publication rights for the original source/icon; enable and test private vulnerability reporting.
3. Perform an owner-authorized live Codex compatibility check, sign-in failure/recovery checks, and release-target OS acceptance. This task used synthetic service responses.
4. Sign/notarize the chosen binary, test a browser-downloaded quarantined app on a separate Mac/fresh account, and approve the final checksum/release notes. Or explicitly scope a source-only developer preview with no ordinary-user readiness claim.
5. Run GitHub CI after the owner authorizes upload; configure enforceable protections and manual release controls.

## Desirable for the first release

- VoiceOver and keyboard navigation review, especially the transparent click-capture control over the SwiftUI meter.
- Real multi-monitor, display reconnect, Spaces/full-screen, and sleep/wake acceptance.
- Define a supported Codex version range and clearer dependency/onboarding guidance from fresh-machine tests.
- Decide whether to migrate settings from existing private builds; exercise rollback if supported.
- Confirm a sensible public update/support policy and test native pointer dragging on another Mac.

## Future enhancements

- Consider persistent app-server notifications only after measuring overhead and reviewing lifecycle/privacy costs.
- Add a provider-independent connection layer only when a real second use case exists.
- Consider an authenticated updater only with signed metadata, review gates, and a clear benefit.
- Investigate Intel support only with real hardware/runtime tests.
- Design a permitted authentication path before offering a paid or hosted Token Meter. Other commercial inventions may use entirely different architectures.

## Community opportunities after repository publication

- Compatibility fixtures containing synthetic data, accessibility improvements, documentation corrections, localization, and multi-display bug reproductions.
- Small, independently testable PRs for known issues. Do not solicit account logs, credential files, or personal usage histories.
- Exhibition contributions: accessible project templates, approved screenshots, verified development journals, and browser-local demos clearly marked as simulations.
