#!/bin/bash
# Builds PenTracker (Release) and packages it into an installable DMG
# with a drag-to-Applications shortcut, at dist/PenTracker.dmg.
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="PenTracker"
DIST_DIR="dist"
STAGING_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGING_DIR"' EXIT

echo "Regenerating Xcode project..."
xcodegen generate

echo "Building $APP_NAME (Release)..."
xcodebuild -project "$APP_NAME.xcodeproj" -scheme "$APP_NAME" -configuration Release \
    -derivedDataPath "$STAGING_DIR/DerivedData" build | tail -5

BUILT_APP="$STAGING_DIR/DerivedData/Build/Products/Release/$APP_NAME.app"
if [ ! -d "$BUILT_APP" ]; then
    echo "error: build did not produce $BUILT_APP" >&2
    exit 1
fi

echo "Staging DMG contents..."
DMG_SRC="$STAGING_DIR/dmg-src"
mkdir -p "$DMG_SRC"
cp -R "$BUILT_APP" "$DMG_SRC/"
ln -s /Applications "$DMG_SRC/Applications"

mkdir -p "$DIST_DIR"
DMG_PATH="$DIST_DIR/$APP_NAME.dmg"
rm -f "$DMG_PATH"

echo "Creating $DMG_PATH..."
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_SRC" -ov -format UDZO "$DMG_PATH"

echo "Done: $DMG_PATH"
