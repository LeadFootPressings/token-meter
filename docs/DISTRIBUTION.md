# Build, package, install, and release

## Local developer build

Use a Mac with Xcode Command Line Tools or Xcode, `xcrun swiftc`, and Python 3. The tested compiler was Apple Swift 6.4.2 with Swift 5 language mode. Dependencies are Apple system frameworks and Python's standard library; no dependency download is required. Do not run an installer just to satisfy this guide if the tools are already available.

```sh
./build.sh
./scripts/test.sh
./scripts/test.sh --ui  # logged-in graphical session
./scripts/package.sh
```

The native build follows the current machine architecture. `ARCH=x86_64 ./build.sh` can cross-compile an Intel candidate, but this does not establish Intel compatibility. There is no universal build claim. The Swift target and Info.plist both specify macOS 13; runtime acceptance on that OS remains required.

Build output is `build/Token Meter.app`; packaging creates `dist/Token-Meter-1.0.7-arm64-local-review.zip` on Apple silicon and an adjacent `.sha256` file. Existing packages are not silently replaced. The ZIP contains the self-contained app bundle, icon, and approved MIT license notice, not Codex, Python, source code, account files, or a login launcher. Codesign verification validates this local signature's integrity; it does not establish trusted public distribution.

## Local installation

For ordinary users of a future approved release: unzip the app, drag it to Applications, then open it. No programming tools are needed. A compatible Codex installation/sign-in is still required. Do not tell users to disable Gatekeeper or run blanket quarantine-removal commands.

The developer installer is intentionally optional:

```sh
./install.sh                    # copy only, no automatic launch or login changes
./install.sh --login            # explicit opt-in to a per-user login launcher
./install.sh --destination /tmp/token-meter-install-test
```

It refuses to overwrite an existing app or launcher. The copy-only path can be tested in a temporary directory without touching the installed app. `--login` is supported only for the default `~/Applications` destination. Its launcher is `~/Library/LaunchAgents/local.tokenmeter.app.plist`. A bootstrap failure leaves the copied app and plist visible for diagnosis; it does not claim a completed login setup.

To disable an intentionally installed launcher:

```sh
launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/local.tokenmeter.app.plist"
```

Then move that specific plist to Trash. Quit Token Meter and move its app to Trash to uninstall. Preferences may remain; remove only the `local.tokenmeter.app` preference domain if you explicitly want a reset. Existing private installations may use a different identifier/launcher; do not remove or migrate them blindly.

## Updates and rollback

There is no automatic updater. Quit the app, retain a versioned copy of the old app, and replace it only after approving the new version. Preserve preferences unless a migration has been tested. If a login launcher exists, verify that its path still points to the intended app; avoid running old and new meters simultaneously. Restore the saved app for rollback. The provisional public bundle identifier requires an owner decision before first publication; migration from the private build is not implemented.

## Public distribution gate

Recommended format: a notarized, Developer ID-signed `.app` in a ZIP, published as a GitHub Release attachment. A drag-install DMG can follow if it materially improves onboarding. A Mac App Store submission is not prepared; the subprocess/credential integration would require a separate sandbox and policy design.

Before the owner authorizes any submission or publication:

1. Verify the approved MIT license and LeadFoot notice; confirm the commit identity, bundle identifier, version, minimum supported OS, and support channel.
2. Test a supported Codex installation/sign-in and failure recovery, macOS 13/current macOS, multi-display behavior, VoiceOver, sleep/wake, and an ordinary fresh user account.
3. Run the offline tests, native UI checks, source/history scan, and a clean-directory build. Review changes since this report.
4. If the owner chooses Apple Developer Program distribution, use their approved Developer ID Application identity. Sign the final app with a secure timestamp and hardened runtime, using only necessary entitlements. No certificate/key is committed.
5. With explicit approval to submit this binary to Apple, use `xcrun notarytool submit` with credentials stored in the owner's Keychain profile. Inspect the result and fix failures; then staple the accepted ticket to the app using `xcrun stapler staple`.
6. Verify with `codesign --verify --deep --strict`, `xcrun stapler validate`, and Gatekeeper assessment. Repackage the stapled app and generate the final checksum. Signing/stapling changes bytes, so the local-review checksum is not a public-release checksum.
7. On a separate Mac/fresh account, download through a browser to exercise quarantine, installation, launch, and the actual Codex dependency. Local launches do not substitute for this test.
8. Prepare release notes and final assets for owner review. Only after explicit authorization create the tag/release, upload the approved assets, and connect website links.

The prepared GitHub workflow does not sign, notarize, upload artifacts, create tags, publish releases, or deploy Pages. No Apple membership, purchase, authentication change, or notarization upload was performed.

References: [Apple Developer ID](https://developer.apple.com/developer-id/) and [Apple notarization workflow](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution). These requirements were reviewed November 5, 2026 and should be rechecked at release time.
