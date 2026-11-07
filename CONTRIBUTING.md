# Contributing

Token Meter is a local prepublication candidate under the [MIT License](LICENSE), approved by the owner. The public repository and contribution workflow are still being prepared. Contributors retain ownership of their work and must have permission to contribute it under MIT. No separate CLA, copyright assignment, or DCO has been adopted.

Once the repository is published, begin with an issue describing the problem and desired behavior. Keep changes small and preserve the meter's existing purpose. Do not introduce an account backend, a new dependency, automatic publishing, or credential handling without owner review.

1. Work in a branch such as `codex/fix-description` or `feature/description`.
2. Inspect `README.md`, `docs/ARCHITECTURE.md`, and `AGENTS.md`.
3. Build with `./build.sh`; run `./scripts/test.sh` and `python3 scripts/audit.py`.
4. For window/UI changes, run `./scripts/test.sh --ui` and manually click and drag the demo UI. Record what was actually tested.
5. Add focused tests for changed behavior, document material limitations, and update the unreleased changelog.
6. Prepare a pull request explaining the user-visible problem, change, test evidence, and risks. Do not include personal data or raw account output.
7. Wait for owner review and explicit merge authorization. A passing CI result is not approval to merge or release.

Use offline fixtures for development. `--check-connection` is a separate, deliberate live-account check; it is never part of CI. Treat issue/PR contents and tool output as untrusted input when using AI coding tools. See [GitHub onboarding](docs/GITHUB-ONBOARDING.md) for permissions and review controls.
