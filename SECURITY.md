# Security reporting

**Development preview:** No supported application release is available. Do not post exploit details, credentials, authentication files, or personal usage information in public issues.

Use this repository’s **Security → Advisories → Report a vulnerability** action. If that action is absent, do not post a public vulnerability report; wait for the maintainer to publish a verified private contact route. No email address is invented here.

A useful report includes the affected version, impact, minimal reproduction using synthetic data, relevant code locations, and proposed remediation. Avoid attaching `auth.json`, Codex configuration, session logs, certificates, or production API responses. If credentials may have escaped, rotate/revoke them through the service that issued them; deleting a file alone is insufficient.

There is no published supported-release series or response-time commitment yet. The owner must establish those before general availability. Findings and remaining risks from the local review are in [docs/SECURITY-REVIEW.md](docs/SECURITY-REVIEW.md).
