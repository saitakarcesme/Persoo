#!/bin/zsh
set -euo pipefail
root="${0:A:h:h}"
build="/tmp/persoo-connect-build"
swift build --package-path "$root/apps/connect" --scratch-path "$build" --jobs 2
app="$build/Persoo Connect.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$build/debug/PersooConnect" "$app/Contents/MacOS/PersooConnect"
cp "$root/apps/connect/bridge.py" "$app/Contents/Resources/bridge.py"
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>app.persoo.connect</string>
<key>CFBundleName</key><string>Persoo Connect</string>
<key>CFBundleExecutable</key><string>PersooConnect</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>NSLocalNetworkUsageDescription</key><string>iPhone ile kendi modelini güvenli biçimde eşleştirmek için.</string>
<key>NSBonjourServices</key><array><string>_persoo._tcp</string></array>
</dict></plist>
PLIST
codesign --force --sign - "$app"
printf '%s\n' "$app"
