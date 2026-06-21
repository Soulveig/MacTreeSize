#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/outputs/MacTreeSize.app"
ZIP_PATH="$ROOT_DIR/outputs/MacTreeSize.zip"
SUBMIT_ZIP="$ROOT_DIR/work/MacTreeSize-notary-submit.zip"
NOTARY_PROFILE="${NOTARY_PROFILE:-mactreesize-notary}"

if [ ! -d "$APP_DIR" ]; then
    echo "Missing $APP_DIR. Build the app first." >&2
    exit 1
fi

codesign --verify --deep --strict --verbose=2 "$APP_DIR"

rm -f "$SUBMIT_ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$SUBMIT_ZIP"

xcrun notarytool submit "$SUBMIT_ZIP" \
    --keychain-profile "$NOTARY_PROFILE" \
    --wait

xcrun stapler staple "$APP_DIR"
xcrun stapler validate "$APP_DIR"
spctl --assess --type execute --verbose=4 "$APP_DIR"

rm -f "$ZIP_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$ZIP_PATH"
xattr -c "$ZIP_PATH" 2>/dev/null || true

echo "Notarized $APP_DIR"
echo "Packaged $ZIP_PATH"
