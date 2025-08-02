#!/bin/sh

if [ "${CONFIGURATION}" = "Release" ]; then
    configFile="$1"

    if [ ! -f "$configFile" ]; then
        echo "Config file does not exist: $configFile"
        exit 1
    fi

    # Read the current project version
    currentVersion=$(grep 'CURRENT_PROJECT_VERSION = ' "$configFile" | cut -d ' ' -f 3)

    # Increment the build number by 1
    newVersion=$((currentVersion + 1))

    # Update build version
    sed -i '' "s/CURRENT_PROJECT_VERSION = .*/CURRENT_PROJECT_VERSION = $newVersion/" "$configFile"
    echo "Build number incremented from $currentVersion to $newVersion"
fi