# Security and privacy review

Review date: November 5, 2026. Scope: retained 1.0.6 project, prepared 1.0.7 source/build/test tooling, available Git metadata, local app/package, and separate exhibition scaffold. This is a practical code and artifact review, not a penetration test or security certification.

## Findings and dispositions

| Priority | Finding | Disposition |
| --- | --- | --- |
| Resolved | Source license and copyright notice were missing | Owner approved MIT; LICENSE added with Copyright (c) 2026 LeadFoot. Public contribution/reporting routes still require setup |
| Release blocker | Ad-hoc signature only; no notarization or quarantined-download acceptance | Local package verified; public signing/distribution remains unperformed |
| Release blocker | Candidate not exercised against a production Codex account | Offline request/response tests pass; explicit live compatibility acceptance remains |
| Release blocker | No public private-vulnerability-reporting route | SECURITY.md prepared; enable and verify the route after the owner approves a repository |
| High, fixed | Finite but enormous numeric input could overflow during conversion to Int; reset countdowns could also overflow | Clamp before conversion, reject booleans/nonfinite and invalid durations/timestamps, bound countdown conversion |
| Medium, fixed | Blocking stdout read/cleanup could outlive the nominal timeout if the child ignored termination | Poll with a monotonic deadline; close owned pipes; bounded grace then kill only the owned child; stalled mock passes |
| Medium, fixed | Child closing stdin could expose the app to SIGPIPE | Disable SIGPIPE on that descriptor; closed-peer regression passes |
| Medium, fixed | Empty/unsupported windows could be reported as successful connection | Require at least one supported duration; retain correct partial-window behavior |
| Medium, mitigated | Raw launch/I/O errors may disclose details; connection check printed personal percentages | Replace with generic app-owned errors and availability-only connection output; raw service errors are never echoed |
| Medium, open | Trust in separately installed Codex executable and its authentication/configuration/network behavior | Fixed conventional paths, no shell/PATH expansion, no bundled binary. No signature/version allowlist or OS-enforced read-only child sandbox |
| Medium, open | Commercial/hosted use of the existing authentication approach is restricted by upstream terms | Documented as a separate architectural gate before a paid/hosted edition |
| Low, fixed | Original build wrote outside its source directory and metadata retained a private identifier | Repository-local generated outputs, matching target/Info.plist minimum OS, provisional neutral identifier; originals preserved privately |
| Low, open | Visual/accessibility and deployment compatibility remain broader than local tests | Full VoiceOver, fresh-account, oldest OS, real display changes, and sleep/wake acceptance remain |

Priority is based on likely reliability/privacy impact in this local desktop architecture. The numeric issue is a crash risk from malformed input, not evidence of remote code execution. No exploited vulnerability or compromised credential was discovered.

## Credentials and personal data

No actual API keys, passwords, access tokens, signing keys, account IDs, or usage-history exports were found in the reviewed original project or prepared publication files. No credential rotation is indicated by the findings. Personal authentication files and Codex session logs were not accessed or copied.

`python3 scripts/audit.py` checks candidate files and reachable historical blobs for common secret formats and personal Mac paths, reporting location/category only. It has no external service dependency and never prints matching values. A regex scan cannot detect every secret, license conflict, or private fact; human review remains necessary. The original bundle identifier was a personal local namespace, not a credential. It survives only in the private checkpoint/provenance and installed predecessor, not publication source.

The current workspace has no commits or remotes. At initial inspection there were zero reachable blobs; `git fsck --full --no-reflogs` passed. The subsequent review also scanned 34 blobs retained in local Codex tree snapshots; these are not user commits. The original project directory is not a Git repository. Therefore there was no prior commit history available to scan or rewrite. No history was deleted, squashed, fabricated, or pushed. Future commits must be scanned before publication; removing a discovered secret from HEAD would not remove it from history.

## Dependencies and permissions

No third-party library/package dependency or lockfile exists. `otool -L` on the built app lists Apple system frameworks and Swift/system libraries. Build helpers use Python's standard library. The icon generator uses local AppKit primitives, and the app uses a system symbol for its menu icon. Ownership provenance still requires the owner's confirmation.

The separately installed Codex program is a runtime dependency and a compatibility/security maintenance responsibility. This review neither audits that external program nor establishes its installed version as supported. The app runs unsandboxed as the user; it requests no Accessibility, screen-recording, admin, or Full Disk Access permission for ordinary operation. UI automation used for this review is separate from the app's requirements.

The prepared CI uses a full commit pin for GitHub's checkout action, read-only repository permissions, no retained credential helper, no deployment/signing secrets, and no artifact upload. Hosted CI has not run because no remote exists. Pinning does not establish that the upstream action has no vulnerabilities; re-review updates and the hosted runner before enabling CI.

The exhibition is static, contains no secrets, uses no remote assets or analytics, and makes no account requests. Its CSP blocks network connections from scripts. It does not provide authentication, payments, or native-app execution.

## Remaining publication review

Inspect the GitHub Desktop Changes list and source export, verify the approved MIT notice and commit identity, complete live/OS/distribution acceptance, and configure owner-controlled repository permissions. Keep `.local-preparation/`, original backups, build caches, local reports, and unsigned review packages out of Git. A local ZIP is not approval to upload it. See the [release checklist](DISTRIBUTION.md).

The upstream commercial-authentication restriction is recorded in the [official OpenAI documentation](https://learn.chatgpt.com/docs/app-server); source license approval does not override it.
