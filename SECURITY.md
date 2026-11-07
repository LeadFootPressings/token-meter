# Security reporting

**Prepublication status:** No public repository or private reporting destination exists yet. Enabling and verifying a confidential reporting channel is a release blocker. Do not post exploit details, credentials, authentication files, or personal usage information in public issues.

Once the repository is public and private vulnerability reporting is enabled, use its **Security → Advisories → Report a vulnerability** action. If that action is absent, do not post a public vulnerability report; wait for the maintainer to publish a verified private contact route. No email address is invented here.

A useful report includes the affected version, impact, minimal reproduction using synthetic data, relevant code locations, and proposed remediation. Avoid attaching `auth.json`, Codex configuration, session logs, certificates, or production API responses. If credentials may have escaped, rotate/revoke them through the service that issued them; deleting a file alone is insufficient.

There is no published supported-release series or response-time commitment yet. The owner must establish those before general availability. Findings and remaining risks from the local review are in [docs/SECURITY-REVIEW.md](docs/SECURITY-REVIEW.md).
