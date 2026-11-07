# Changelog

No public release has been published. Earlier entries summarize the original local README and retained 1.0.6 source; they are not reconstructed Git commits. No release dates are assigned here.

## 1.0.7 — Unreleased review candidate

- Apply the owner-approved MIT license with Copyright (c) 2026 LeadFoot; include the notice in built app bundles.
- Document staged GitHub permissions and the LeadFoot Pressings collection identity.

- Make build, test, and package paths relative to the repository; explicitly target macOS 13.
- Harden numeric parsing against overflow, booleans, invalid durations, and invalid reset dates.
- Bound stdio reads and cleanup, including a child that ignores termination; withhold raw service errors.
- Treat empty/unsupported allowance windows as unavailable and keep partial windows distinct.
- Discover compatible app bundles in the user's Applications folder as well as system Applications.
- Add offline transport/parser tests and isolated demo/UI test preferences.
- Preserve the native meter, click/drag, shared placement, and host lifecycle behavior.
- Add real synthetic-data UI previews, publication documentation, security review, and CI checks without deployment.
- Use provisional `local.tokenmeter.app` for review; no migration from the private build's preferences.

## 1.0.6 — Local predecessor

Drag the meter without cumulative pointer drift; save and restore accessible coordinates; persist Reset Screen Position.

## 1.0.5 — Local predecessor

Collapse settings when selecting On desktop; allow deliberate reopening and keep reopened settings visible when reapplying placement.

## 1.0.3 — Local predecessor

Apply window placement to both meter and settings.

## 1.0.2 — Local predecessor

Keep desktop-mode windows clickable and nonactivating.

## 1.0.1 — Local predecessor

Capture the first physical click across the meter and open persistent settings.

## Original local implementation

Twin allowance rings, reset countdowns, read-only request sequence, host-app lifecycle, and three-minute polling. Version 1.0.4 has no distinct retained release note; none is invented.
