#!/bin/bash
# Tests, builds, signs, and installs WheelFlip into /Applications.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build

# Assertions must stay on, so the test build does not use -O.
swiftc -o build/tests Sources/Scroll.swift Tests/main.swift
build/tests

APP=build/WheelFlip.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp Info.plist "$APP/Contents/Info.plist"
cp Assets/AppIcon.icns Assets/MenuBarIconTemplate*.png "$APP/Contents/Resources/"
swiftc -O -o "$APP/Contents/MacOS/WheelFlip" Sources/Scroll.swift Sources/main.swift

# A real certificate keeps the Accessibility grant across rebuilds. An ad-hoc signature loses it each time.
IDENTITY=$(security find-identity -v -p codesigning | awk '/Apple Development/ {print $2; exit}')
codesign --force --options runtime --sign "${IDENTITY:--}" "$APP"

pkill -x WheelFlip || true
rm -rf /Applications/WheelFlip.app
cp -R "$APP" /Applications/WheelFlip.app
open /Applications/WheelFlip.app
