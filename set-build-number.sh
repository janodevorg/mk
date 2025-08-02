#!/bin/sh

if [ "${CONFIGURATION}" = "Release" ]; then
    configFile="$1"

    if ! command -v git > /dev/null 2>&1
    then
        echo "git command not found, aborting."
        exit 1
    fi

    if [ ! -f "$configFile" ]; then
        echo "Config file does not exist: $configFile"
        exit 1
    fi

    # Read the current project version
    currentVersion=$(grep 'CURRENT_PROJECT_VERSION = ' "$configFile" | cut -d ' ' -f 3)

    # Determine the number of commits on the main branch
    commitCount=$(git rev-list --count main)

    if [ "$currentVersion" -eq "$commitCount" ]; then
        echo "Build number didn’t change: $currentVersion"
    else
        # Update build version to the number of commits
        sed -i '' "s/CURRENT_PROJECT_VERSION = .*/CURRENT_PROJECT_VERSION = $commitCount/" "$configFile"
        echo "Build number incremented from $currentVersion to $commitCount"
    fi
fi
