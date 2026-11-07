# GitHub setup and publication permissions

Status: **planning only**. GitHub Desktop and the account are not yet ready. No setup, login, remote creation, push, public release, or permission change is authorized by this checklist. The owner will tell us when to begin.

Project: Token Meter. Collection: **LeadFoot Pressings**. MIT is approved and applied with Copyright (c) 2026 LeadFoot. The collection name does not presume an Organization, available username, domain, or legal company identity.

## Already authorized locally

Inspect and improve this workspace, make recoverable checkpoints, run offline checks, maintain documentation, and revise the local exhibition prototype. No extra blanket permission is needed for those ordinary reversible tasks. This website revision does not require rebuilding, reinstalling, or querying the native app.

## Stages to authorize when ready

| Stage | Permission requested | Concrete result to review before the next stage |
| --- | --- | --- |
| 1. Local GitHub Desktop preparation | Operate GitHub Desktop to add the existing local repository; use the owner-selected commit name/email; create the reviewed first local commit and subsequent working branches | File list, diff, author identity, ignored-file check, test results, and local commit. No upload |
| 2. Initial remote upload | Create explicitly named repositories under the chosen personal account or Organization, choose private/public visibility, set the matching remote, and push the approved contents | Exact owner/repository names, visibility, source commit, and upload scope shown first. A private push still transmits files to GitHub |
| 3. Repository controls | Configure approved branch protection/rulesets, confidential vulnerability reporting, contributor access, and CI settings for these repositories only | Reviewable settings list. No blanket administrator token, bypass access, auto-merge, or unrestricted publisher |
| 4. CI execution | Enable/run the prepared build-and-test workflow after confirming the permitted billing/free-usage conditions | First hosted results, failures, and remaining local-versus-hosted differences. No paid runner usage or spending changes without separate approval |
| 5. Live application acceptance | Run a deliberate read-only Codex allowance compatibility check and any specifically agreed host/display tests | Availability result and privacy-preserving evidence. No model generation, credential copying, account-history export, or interruption of ongoing work |
| 6. Signed application distribution | Use an approved Developer ID identity to sign the chosen binary; submit that binary to Apple's notarization service; optionally install the reviewed replacement | Exact app/version, signature, notarization result, checksum, and fresh-install validation. Login startup is a separate opt-in |
| 7. Public publication | Make the reviewed repositories public, create the approved tag/release, upload the exact approved release files, and enable the approved exhibition hosting | Exact public destinations, source commit, version, assets, and site preview. Each publication destination must be named |
| 8. Ongoing development | Push approved working branches and prepare PRs within an agreed scope | Diffs and passing checks. Protected-branch merges, significant repository changes, and releases continue to need owner authorization |

Stages may be approved together when the exact scope is known, but approval for local preparation does not imply remote upload or publication. Approval persists for its stated scope; it does not need to be requested again for every routine step. The owner can narrow or withdraw it.

The prepared CI runs on pushes to main and pull requests. Before the first push, check whether it could trigger billable execution. If that cannot be established, defer CI or use an explicitly approved initial upload with Actions disabled. GitHub Desktop's Publish operation creates the remote and sends code; it is not merely a local preview.

## What the owner should do personally

- Install GitHub Desktop from its official source, create/select the account and username, and complete sign-in, account terms, passkey/password, and two-factor steps.
- Supply the intended public commit name and email (or GitHub noreply email). The copyright holder LeadFoot need not be the Git commit identity.
- Choose personal-account versus Organization ownership and the repository names/visibility. LeadFoot Pressings can be the display identity without assuming an available GitHub handle.
- Approve security-sensitive connection grants and any macOS permission prompt if UI automation actually needs it. No new Accessibility, screen-recording, Full Disk Access, or system setting is requested in advance.
- Keep passwords, recovery codes, signing keys, and access tokens out of chat and repository files. No credential value is needed for this planning stage.

Account creation, authentication changes, and legal acceptance remain owner-controlled. No Organization, membership, paid plan, custom domain, or Apple Developer purchase is required just to import the repository locally.

## Optional GitHub MCP access

GitHub Desktop can handle the initial Git workflow; MCP is optional. If added later, begin with read-only access to the selected repositories and only the content, issue/PR, and workflow-result tools needed for inspection. Use the provider's supported credential flow rather than pasting a token here.

After an explicit writing task is approved, grant only the required repository-scoped capabilities: content/branch writes and pull-request writes for proposed changes; issue writes only for issue maintenance. Workflow-file writes need their own reviewed CI scope. Do not request organization administration, repository deletion, unrestricted secrets, signing access, or ruleset bypass. Repository settings can be configured through an individually approved owner session rather than permanent broad agent credentials.

If a fine-grained token is needed, restrict it to the selected owner/repositories, use an expiration, and retain only necessary permissions. The available authentication method and exact permission names will be checked when connecting. A tool allowlist does not reduce what the underlying credential can do; enforce branch/release approval using repository controls too. Review the solo-maintainer self-approval caveat in [GITHUB-ONBOARDING.md](GITHUB-ONBOARDING.md).

## Systematic execution order

1. Confirm the running app/account and selected owner without reading credentials.
2. Re-audit source, ignore rules, MIT notice, author identity, and current test evidence.
3. Import locally and prepare a reviewed local commit.
4. Present the exact upload and CI scope; obtain the applicable approval.
5. Create/upload only approved repositories, then verify protection, confidential reporting, and hosted checks.
6. Complete live/platform/distribution acceptance.
7. Present the final source, binary, and website for approval before public release/deployment.

References reviewed November 5, 2026: [GitHub Desktop local import](https://docs.github.com/en/desktop/adding-and-cloning-repositories/adding-a-repository-from-your-local-computer-to-github-desktop), [publishing an existing project](https://docs.github.com/en/desktop/adding-and-cloning-repositories/adding-an-existing-project-to-github-using-github-desktop), and [GitHub credential permissions](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).
