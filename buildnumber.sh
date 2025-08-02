#!/usr/bin/env bash

# Script to set build number from git commits count
# This is commonly used as a post-build script in Xcode projects

# Get the git commit count
GIT_COMMIT_COUNT=$(git rev-list HEAD --count)

if [ -z "$GIT_COMMIT_COUNT" ]; then
    echo "Warning: Could not determine git commit count"
    exit 0
fi

echo "Setting build number to: $GIT_COMMIT_COUNT"

# Update the Info.plist with the build number
if [ -n "$INFOPLIST_FILE" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $GIT_COMMIT_COUNT" "$INFOPLIST_FILE"
    echo "Updated $INFOPLIST_FILE with build number: $GIT_COMMIT_COUNT"
else
    echo "Warning: INFOPLIST_FILE environment variable not set"
fi