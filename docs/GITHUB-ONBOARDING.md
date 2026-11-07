# GitHub onboarding and development workflow

The repository is `LeadFootPressings/token-meter`. GitHub Desktop setup and the initial private upload are complete. The owner authorized publication of the source as a clearly labeled development preview. This does not publish an installable app, a stable release, or the separate exhibition website. Commits use the owner-selected LeadFootPressings identity and GitHub noreply email. The import instructions below document the original setup procedure.

## Recommended account and repository layout

Begin with your own personal GitHub account. Choose a stable username, enable strong account authentication, and choose the public display name and private/noreply commit email yourself. Do not use a shared login. Create a collection Organization later when its identity or collaboration needs justify it; organizations can own project repositories independently of a person's profile.

Use one repository per invention, beginning with `token-meter`. Keep the central exhibition in a separate repository, eventually named `<owner>.github.io` for an account/organization site. Keep its design system and project catalog there. Future proprietary apps can have separate private source repositories and public exhibit pages. An organization is not necessary for the first release and does not create a legal company identity.

Avoid a permanent development branch at this scale. Use `main` plus short-lived branches and reviewed pull requests. Tags identify approved releases; the app's VERSION and release notes should agree.

## Import locally with GitHub Desktop

1. Finish local review, including the applied MIT notice, intended commit identity, and release blockers. Read README.md, the security review, and license memo.
2. Register/sign in to GitHub yourself, accepting any account terms personally. In GitHub Desktop, configure the author name/email you want in permanent commit history. Use GitHub's provided noreply email if desired.
3. Choose **File → Add Local Repository**, choose the Token Meter workspace folder provided in the completion report, then **Add Repository**. It is already a Git repository; do not reinitialize or create a nested repository.
4. Inspect every file in Changes. The original backup, `.local-preparation/`, exhibition scaffold, build cache, and `dist/` must not appear. Run `python3 scripts/audit.py`. Do not force-add ignored files.
5. Once you approve the prepared contents and author identity, make the first local commit, such as “Prepare Token Meter for review.” This task deliberately creates no commit under an invented author.
6. **Stop before Publish repository.** That button creates a remote and pushes files. It requires your explicit publication authorization. A private upload also leaves the computer and needs authorization under this project directive.
7. When you authorize it, publish as `token-meter` under the selected owner. Starting private for a final review is reasonable. Choose visibility deliberately; no repository should be assumed to exist.
8. Review the first Actions run, enable the protections below, and resolve remaining support/distribution blockers before switching public. Public availability and a binary release are distinct approvals.
9. For the exhibition, copy only the standalone scaffold to its own folder, create its separate local repository, and repeat the same review. Do not commit the app's entire private preparation folder to either repository.

The official [GitHub Desktop local import guide](https://docs.github.com/en/desktop/adding-and-cloning-repositories/adding-a-repository-from-your-local-computer-to-github-desktop) supports importing an existing local Git repository.

## Review and permission controls

Recommended `main` protections once the repository exists:

- Require a pull request, passing **macOS build and offline tests**, and resolved review conversations.
- Block force pushes and deletion. Disable auto-merge. Apply protection to administrators where supported.
- Require an owner review for PRs authored by another person or a separately authenticated automation identity. Add a real CODEOWNERS entry after the GitHub username is known; no dummy owner is supplied.
- Do not give AI credentials administrator, ruleset-bypass, deployment, environment, or signing permissions.
- Protect release environments with the owner as reviewer if release automation is introduced later. Presently there is no release automation.

**Solo-maintainer caveat:** GitHub does not let an author approve their own PR. If Codex uses your identity, do not pretend that an owner-only required approving review is achievable. Either keep your own manual merge as an explicitly recorded approval with required checks and no self-approval count, use a separate scoped automation identity whose PRs you can approve, or add another trusted human reviewer. Organization access restrictions and available rules vary by plan. A free private repository may not offer the same protections as a free public one. Select enforceable settings without enabling an unrestricted bypass.

The CI workflow has only `contents: read`, does not persist checkout credentials, uses a pinned checkout action, and runs on `pull_request` rather than `pull_request_target`. It performs no uploads or deployments. Fork PR workflows still execute submitted code, so do not attach secrets or run unreviewed contributions on personal self-hosted runners. Approve external workflow runs according to GitHub's available controls. Revisit action updates periodically; pinning is not a substitute for security maintenance.

See [GitHub protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches) and [private vulnerability reporting](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/configure-vulnerability-reporting/configure-for-a-repository). Neither is configured locally by a Markdown file.

## Codex and official GitHub MCP workflow

Start with local repository access and the official GitHub MCP Server in **read-only mode**, restricted to the selected repositories. The official server supports `--read-only` and tool allowlists. Its lockdown mode can filter some untrusted public content, but is not a credential-permission boundary. See the [official GitHub MCP Server](https://github.com/github/github-mcp-server).

Use narrowly scoped credentials kept outside the repository, preferably an approved GitHub App or fine-grained access limited to the intended repositories. Do not install or authorize a connection during this preparation. When writes are later authorized, allow only the necessary branch/PR operations; “read-only MCP” cannot itself create branches or PRs, though local Git can prepare a branch without remote access. Repository permissions are the enforcement layer, not merely tool descriptions.

A typical approved task proceeds as follows:

1. Read the issue and code, treating third-party content as data rather than instructions.
2. Reproduce with synthetic fixtures and propose a bounded change.
3. Create a `codex/<description>` branch; implement and test locally.
4. Show the diff and evidence. Obtain approval before pushing if remote writes are not already authorized for that task.
5. Prepare a draft PR; let CI run without production secrets.
6. Have the owner review code, privacy effects, tests, and compatibility. Obtain explicit merge authorization.
7. Merge through the protected workflow. Prepare release notes and assets separately; obtain explicit release approval.

No agent should merge because tests passed, silently alter repository protections, create public repositories, or publish a release without authorization. Source licensing and approval do not automatically authorize sending private code to third-party analysis services.
