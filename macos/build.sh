#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ "$(uname -sm)" == "Darwin arm64" ]] || { echo "Run on an Apple Silicon Mac." >&2; exit 1; }
unset SSD_RECOMP_FILE
export CARGO_TARGET_DIR="${CARGO_TARGET_DIR:-$PWD/target}"
cargo build --locked --release -p ssd-app --target aarch64-apple-darwin
out=$(mktemp -d "${CARGO_TARGET_DIR}/macos.XXXXXXXX")
app="$out/DBZ SSD RC2.app"
a="$app/Contents"
mkdir -p "$a/MacOS" "$a/Resources/fonts" "$a/Resources/licenses"
cp macos/Info.plist "$a/"
cp "$CARGO_TARGET_DIR/aarch64-apple-darwin/release/ssd-recompiled" "$a/MacOS/"
cp translations/zh-tw/*.tsv translations/zh-hk/*.tsv "$a/Resources/"
cp translations/zh-tw/fonts/LXGWWenKaiTC-Regular.ttf "$a/Resources/fonts/"
cp LICENSE LICENSE-ART.md NOTICE.md translations/zh-tw/licenses/* "$a/Resources/licenses/"
cp macos/README.md "$a/Resources/"
xcrun swiftc -O macos/Launcher.swift -o "$a/MacOS/DBZLauncher"
lipo -verify_arch arm64 "$a/MacOS/DBZLauncher"
lipo -verify_arch arm64 "$a/MacOS/ssd-recompiled"
codesign --force --sign - "$a/MacOS/ssd-recompiled"
codesign --force --sign - "$app"
codesign --verify --deep --strict "$app"
plutil -lint "$a/Info.plist"
echo "$app"
