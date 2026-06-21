# MacTreeSize

MacTreeSize is a small native macOS disk usage viewer inspired by TreeSize.

Current version: 0.5.38

Copyright © 2026 Golovatyuk Alexey

## Features

- Choose any folder and scan it recursively.
- See folders and files sorted by size.
- Expand and collapse the tree.
- View allocated disk size, share of the selected root, file count, and folder count.
- Filter tiny entries with the minimum-percent slider.
- Hide or show individual files.
- Stop a running scan.
- See live scan counters for scanned items, files, folders, and bytes.
- See used bytes as a percentage of the selected disk volume capacity.
- Open macOS Full Disk Access settings and check whether protected folders are readable.
- View the app version and changelog inside the app.
- Check for updates and install a downloaded update from inside the app.
- Switch the interface language between English, Russian, German, French, Spanish, and Chinese.
- Includes an original app icon stored at `assets/MacTreeSizeIcon.png`.

## Local install note

The app bundle is ad-hoc signed for local development builds. If macOS says the app is damaged after it was downloaded through Telegram, a browser, or another quarantining app, remove the quarantine attribute locally:

```sh
xattr -dr com.apple.quarantine /Applications/MacTreeSize.app
```

For public distribution without this step, sign with an Apple Developer ID certificate and notarize the app.

## Update manifest

MacTreeSize checks `https://mactreesize.ru/update/update.json` for updates. If `MTUpdateManifestURL` points to a folder, the app automatically appends `update.json`.

```json
{
  "version": "0.5.38",
  "downloadURL": "https://mactreesize.ru/update/MacTreeSize-0.5.38.zip",
  "releaseNotes": "Adds an in-app language selector and localizes the main MacTreeSize interface."
}
```

## License

All rights reserved. See [LICENSE](LICENSE).

## Full Disk Access

macOS does not allow apps to grant Full Disk Access to themselves. Use the in-app **Open Settings** button, add `MacTreeSize.app` in Privacy & Security > Full Disk Access, enable it, then relaunch the app.

## Run From Source

```sh
swift run -c release MacTreeSize
```

## Build A macOS App Bundle

```sh
./scripts/build-app.sh
open outputs/MacTreeSize.app
```

By default the build uses an ad-hoc signature for local testing. For public distribution, install a `Developer ID Application` certificate in Keychain and pass its identity:

```sh
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./scripts/build-app.sh
```

Store notarization credentials once in Keychain:

```sh
xcrun notarytool store-credentials mactreesize-notary
```

Then notarize and staple the built app:

```sh
NOTARY_PROFILE=mactreesize-notary ./scripts/notarize-app.sh
```

The app uses SwiftUI and requires macOS 13 or newer.
