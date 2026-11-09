#!/bin/bash
# Builds the universal, ad-hoc signed release zip in build/release and prints its SHA-256.
set -euo pipefail
cd "$(dirname "$0")"

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Info.plist)
OUT=build/release
APP=$OUT/WheelFlip.app
rm -rf "$OUT"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp Info.plist "$APP/Contents/Info.plist"
cp Assets/AppIcon.icns Assets/MenuBarIconTemplate*.png "$APP/Contents/Resources/"

for ARCH in arm64 x86_64; do
    swiftc -O -target "$ARCH-apple-macos13" -o "$OUT/WheelFlip-$ARCH" Sources/Scroll.swift Sources/main.swift
done
lipo -create -output "$APP/Contents/MacOS/WheelFlip" "$OUT/WheelFlip-arm64" "$OUT/WheelFlip-x86_64"
rm "$OUT"/WheelFlip-arm64 "$OUT"/WheelFlip-x86_64

# Ad-hoc signing keeps personal certificate details out of the public binary.
codesign --force --options runtime --sign - "$APP"
codesign --verify --strict "$APP"
codesign -dv "$APP" 2>&1 | grep "flags=.*runtime" >/dev/null

ditto -c -k --norsrc --noextattr --keepParent "$APP" "$OUT/WheelFlip-$VERSION.zip"
shasum -a 256 "$OUT/WheelFlip-$VERSION.zip"
