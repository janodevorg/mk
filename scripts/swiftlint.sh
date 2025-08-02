#!/bin/sh

### COPY CONFIG

# 1. Figure out the root Derived Data path by going up from $PROJECT_TEMP_DIR
DERIVED_DATA_DIR="$(cd "$PROJECT_TEMP_DIR"/../../.. && pwd)"
echo "Derived Data directory is: $DERIVED_DATA_DIR"

# 2. Paths to your SwiftLint config files in the project folder
SOURCE_FILE_MAIN="$SRCROOT/.swiftlint.yml"
SOURCE_FILE_CHILD="$SRCROOT/mk/.swiftlint-refinement.yml"

# 3. Copy both files into Derived Data
#    (You'll only copy what's actually there—if either is missing, it logs a warning.)
for FILE in "$SOURCE_FILE_MAIN" "$SOURCE_FILE_CHILD"; do
  BASENAME=$(basename "$FILE")
  if [ -f "$FILE" ]; then
    cp "$FILE" "$DERIVED_DATA_DIR/$BASENAME"
    echo "Copied $BASENAME to $DERIVED_DATA_DIR"
  else
    echo "warning: $FILE not found. Skipping."
  fi
done

### RUN SWIFTLINT

###
# 1. Determine SwiftLint path with fallback
###
SWIFTLINT="/opt/homebrew/bin/swiftlint"
if ! command -v "$SWIFTLINT" >/dev/null 2>&1; then
  if ! command -v swiftlint >/dev/null 2>&1; then
    echo "error: SwiftLint not found. Install it via Homebrew or https://github.com/realm/SwiftLint"
    exit 1
  else
    SWIFTLINT="swiftlint"
  fi
fi

###
# 2. Path to SwiftLint config
#    Adjust if your .swiftlint.yml is in a different location.
###
CONFIG_FILE=".swiftlint.yml"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "warning: $CONFIG_FILE not found, continuing without explicit config."
  CONFIG_FILE=""
fi

###
# 3. Create temp file and set trap to remove it
###
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

###
# 4. Gather changed, staged, or untracked Swift files in Sources/
###
git status --porcelain \
  | grep -E '^(M|A|\?\?) ' \
  | awk '{print $2}' \
  | grep '^Sources/.*\.swift$' \
  > "$temp_file"

###
# 5. Export files as SCRIPT_INPUT_FILE_x so SwiftLint can use --use-script-input-files
###
counter=0
while read -r file; do
  # Sort and uniq are omitted in the while loop approach because we’re reading line by line.
  # If you want them, add an extra step to filter duplicates:
  #   sort "$temp_file" | uniq | while read -r file; do ...
  if [ -n "$file" ]; then
    eval "export SCRIPT_INPUT_FILE_$counter=\"$file\""
    counter=$((counter + 1))
  fi
done < "$temp_file"

if [ $counter -gt 0 ]; then
  export SCRIPT_INPUT_FILE_COUNT="$counter"
  
  if [ -n "$CONFIG_FILE" ]; then
    "$SWIFTLINT" autocorrect --config "$CONFIG_FILE" --use-script-input-files
  else
    "$SWIFTLINT" autocorrect --use-script-input-files
  fi
fi
