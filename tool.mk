.PHONY: build build-xcode clean test run clean-db

# Cache file for tool path
TOOL_CACHE_FILE := ./.tool_path_cache
TOOL_NAME = $(shell echo $(PROJECT_NAME) | tr '[:upper:]' '[:lower:]')

# Target to find the tool path - only executed when called
# @help:tool-find: Locate the path to the built tool
.PHONY: tool-find
tool-find:
	@if [ -x "./.build/arm64-apple-macosx/debug/$(TOOL_NAME)" ]; then \
		echo "./.build/arm64-apple-macosx/debug"; \
	else \
		echo "Locating $(TOOL_NAME) (this may take a moment)..." 1>&2; \
		echo ""; \
	fi

# Verify that the built tool exists and display its help
# @help:tool-help: Build the tool and display its help information
.PHONY: tool-help
tool-help: build
	@TOOL_PATH=$$($(MAKE) -s tool-find); \
	echo "Checking for $(TOOL_NAME) in $$TOOL_PATH..."; \
	if [ -x "$$TOOL_PATH/$(TOOL_NAME)" ]; then \
		echo "Found $(TOOL_NAME); displaying help:"; \
		"$$TOOL_PATH/$(TOOL_NAME)" --help; \
	else \
		echo "Error: $(TOOL_NAME) not found or not executable at $$TOOL_PATH" >&2; \
		exit 1; \
	fi

# Copy the generated tool to current directory
# @help:tool-copy: Build and copy the tool to the current directory
.PHONY: tool-copy
tool-copy: build
	@echo "Copying $(TOOL_NAME) tool to current directory..."; \
	if [ -x "./.build/arm64-apple-macosx/debug/$(TOOL_NAME)" ]; then \
		cp "./.build/arm64-apple-macosx/debug/$(TOOL_NAME)" ./$(TOOL_NAME); \
		chmod +x ./$(TOOL_NAME); \
		echo "Tool copied successfully to ./$(TOOL_NAME)"; \
	else \
		echo "Error: '$(TOOL_NAME)' tool not found or not executable in ./.build/arm64-apple-macosx/debug/" >&2; \
		exit 1; \
	fi
