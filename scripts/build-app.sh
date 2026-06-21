#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/outputs/MacTreeSize.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ICON_SOURCE="$ROOT_DIR/assets/MacTreeSizeIcon.png"
ICONSET_DIR="$ROOT_DIR/work/MacTreeSize.iconset"
CODESIGN_IDENTITY="${CODESIGN_IDENTITY:--}"

cd "$ROOT_DIR"
swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$ROOT_DIR/.build/release/MacTreeSize" "$MACOS_DIR/MacTreeSize"
chmod +x "$MACOS_DIR/MacTreeSize"

if [ -f "$ICON_SOURCE" ]; then
    rm -rf "$ICONSET_DIR"
    mkdir -p "$ICONSET_DIR"
    sips -z 16 16 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
    sips -z 32 32 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
    sips -z 32 32 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
    sips -z 64 64 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
    sips -z 128 128 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
    sips -z 256 256 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
    sips -z 256 256 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
    sips -z 512 512 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
    sips -z 512 512 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
    sips -z 1024 1024 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null
    iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/MacTreeSize.icns"
fi

cat > "$CONTENTS_DIR/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>MacTreeSize</string>
    <key>CFBundleIdentifier</key>
    <string>com.golovatyuk.mactreesize</string>
    <key>CFBundleName</key>
    <string>MacTreeSize</string>
    <key>CFBundleDisplayName</key>
    <string>MacTreeSize</string>
    <key>CFBundleIconFile</key>
    <string>MacTreeSize</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.5.39</string>
    <key>CFBundleVersion</key>
    <string>53</string>
    <key>MTUpdateManifestURL</key>
    <string>https://mactreesize.ru/update/</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Golovatyuk Alexey</string>
    <key>NSDocumentsFolderUsageDescription</key>
    <string>MacTreeSize needs access to update itself when the app is run from your Documents folder.</string>
    <key>NSDesktopFolderUsageDescription</key>
    <string>MacTreeSize needs access to update itself when the app is run from your Desktop folder.</string>
    <key>NSDownloadsFolderUsageDescription</key>
    <string>MacTreeSize needs access to update itself when the app is run from your Downloads folder.</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

if [ "$CODESIGN_IDENTITY" = "-" ]; then
    echo "Signing with ad-hoc identity"
    xattr -cr "$APP_DIR" 2>/dev/null || true
    codesign --force --deep --sign - "$APP_DIR" >/dev/null
else
    echo "Signing with $CODESIGN_IDENTITY"
    xattr -cr "$APP_DIR" 2>/dev/null || true
    codesign --force --deep --options runtime --timestamp --sign "$CODESIGN_IDENTITY" "$APP_DIR" >/dev/null
fi
codesign --verify --deep --strict --verbose=2 "$APP_DIR"
xattr -cr "$APP_DIR" 2>/dev/null || true

echo "Built $APP_DIR"
