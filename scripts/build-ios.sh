#!/bin/zsh
set -euo pipefail
root="${0:A:h:h}"
xcodegen generate --spec "$root/apps/ios/project.yml"
xcodebuild -project "$root/apps/ios/Persoo.xcodeproj" -scheme Persoo -sdk iphonesimulator -configuration Debug -derivedDataPath /tmp/persoo-ios-build -jobs 2 ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO build
