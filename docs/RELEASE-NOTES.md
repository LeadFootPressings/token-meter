# Proposed first public release: 1.0.7

**Draft for review. Unreleased.** Version 1.0.7 continues the existing local 1.0.6 lineage; no public release date or tag has been assigned.

Token Meter is a small native Mac companion for checking remaining five-hour and weekly Codex allowance percentages. It offers movable twin rings, low-allowance colors, reset countdowns, manual refresh, and a choice of always-on-top or desktop placement.

This candidate makes the build portable, adds offline regression coverage, hardens malformed-response and timeout handling, and prepares user/developer documentation. It preserves the existing meter's purpose and UI behavior.

The local package is Apple-silicon-only and targets macOS 13 or later, with runtime testing currently limited to macOS 27.0.1. A separately installed compatible Codex executable and sign-in are required. These are quota percentages, not literal token counts, billing, or per-chat measurements.

The owner approved MIT licensing with Copyright (c) 2026 LeadFoot. Before publication: confirm the bundle identifier and support matrix, verify live compatibility, complete trusted signing/notarization and fresh-user download testing, configure private security reporting, and approve the final notes/assets. The current ZIP is ad-hoc signed for local review only. There is no automatic updater and no public download link yet.
