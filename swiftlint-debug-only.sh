#!/usr/bin/env bash

# Only run SwiftLint in Debug configuration
if [ "${CONFIGURATION}" != "Debug" ]; then
    echo "SwiftLint: Skipping in ${CONFIGURATION} configuration"
    exit 0
fi

# Run the original swiftlint script
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
"${script_path}/swiftlint.sh"