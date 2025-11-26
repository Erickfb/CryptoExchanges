#!/bin/bash

# SwiftLint Run Script
# This script runs SwiftLint to enforce code style and conventions

if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"

  # Try to use SwiftLint from Swift Package Manager
  if [ -f "${BUILD_DIR%Build/*}SourcePackages/artifacts/swiftlint/SwiftLint/swiftlint.artifactbundle/swiftlint-0.54.0-macos/bin/swiftlint" ]; then
    "${BUILD_DIR%Build/*}SourcePackages/artifacts/swiftlint/SwiftLint/swiftlint.artifactbundle/swiftlint-0.54.0-macos/bin/swiftlint"
  fi
fi
