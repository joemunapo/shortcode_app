# Shortcode

Shortcode is a small Android utility for building, previewing, and dialing
EcoCash agent USSD shortcodes.

Package name: `shortcode.fintraqr.com`

## Features

- Agent to Agent
- Cash In
- Buy Airtime
- Cash Deposit
- Zimbabwe phone number normalization
- Contact picker and paste shortcuts
- Native Android share links for Joe Munapo's work

## Release Builds

Build the Play Store bundle:

```sh
flutter build appbundle --release --tree-shake-icons --obfuscate --split-debug-info=build/symbols
```

Build split APKs for device testing:

```sh
flutter build apk --release --split-per-abi --tree-shake-icons --obfuscate --split-debug-info=build/symbols
```

Primary outputs:

- `build/app/outputs/bundle/release/app-release.aab`
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

## Signing

Release builds read signing config from `android/key.properties`. This file is
local-only and ignored by git.

## Privacy Policy

Google Play privacy policy:

https://joemunapo.github.io/shortcode_app/privacy-policy/
