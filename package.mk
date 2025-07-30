# ===========================================
# Makefile content for Packages
# ===========================================

# You must define PROJECT_NAME in the Makefile that imports this file
# This is imported by the Makefile in the Xcode project

# Mark this as a package project to avoid target conflicts
PROJECT_TYPE = package

# Auto‑generated scheme when a Swift‑PM package is opened in Xcode
PACKAGE_SCHEME  = $(PROJECT_NAME)-Package

# Include common configuration
include $(MK_DIR)/config.mk
include $(MK_DIR)/help.mk
include $(MK_DIR)/coverage.mk
include $(MK_DIR)/docc-package.mk
include $(MK_DIR)/tuist.mk

# ===========================================
# Default target - replaced by auto-generated help
# ===========================================

# ===========================================
# Simulator Utilities
# ===========================================
# @help:list-simulators: List available iOS simulators
.PHONY: list-simulators
list-simulators:
	@echo "$(BLUE)Available simulators:$(RESET)"
	xcrun simctl list devices

# ===========================================
# Build / Clean
# ===========================================
# @help:build: Build the project with Swift Package Manager
.PHONY: build
build:
	@echo "$(BLUE)Building $(PROJECT_NAME)...$(RESET)"
	swift build $(SWIFT_BUILD_FLAGS) | xcbeautify

# @help:clean: Clean build artifacts and cached files
.PHONY: clean
clean:
	@echo "$(BLUE)Cleaning $(PROJECT_NAME)...$(RESET)"
	rm -rf .build
	rm -rf .docc-build
	rm -f coverage-summary.txt
	rm -f default.profraw
	swift package clean

# ===========================================
# Tests
# ===========================================
# @help:build-and-test: Build the project and run all tests
.PHONY: build-and-test
build-and-test: build test

# @help:test: Run all tests with code coverage enabled
.PHONY: test
test:
	@echo "$(BLUE)Running tests for $(PROJECT_NAME)...$(RESET)"
	[ -d "coverage" ] && rm -rf coverage || true
	swift test --enable-code-coverage $(SWIFT_BUILD_FLAGS) --enable-experimental-swift-testing --disable-sandbox

# @help:test-file: Run tests for a specific file (usage: make test-file TEST_FILE=YourTestFileName)
.PHONY: test-file
test-file: build
	@if [ -z "$(TEST_FILE)" ]; then \
		echo "Error: You must specify a file using TEST_FILE=YourTestFileName"; \
		exit 1; \
	fi
	@echo "$(BLUE)Running tests for file $(TEST_FILE) in $(PROJECT_NAME)...$(RESET)"
	@swift test --filter "$(TEST_FILE)" $(SWIFT_BUILD_FLAGS) --enable-code-coverage --disable-sandbox

# @help:test-method: Run a specific test method (usage: make test-method TEST_FILE=YourTestFileName METHOD=yourTestMethod)
.PHONY: test-method
test-method: build
	@if [ -z "$(TEST_FILE)" ] || [ -z "$(METHOD)" ]; then \
		echo "Error: You must specify both TEST_FILE and METHOD"; \
		exit 1; \
	fi
	@echo "$(BLUE)Running test method $(METHOD) in $(TEST_FILE)...$(RESET)"
	@if echo "$(TEST_FILE)" | grep -q "\." ; then \
		swift test --filter "$(TEST_FILE)/$(METHOD)" $(SWIFT_BUILD_FLAGS) --enable-code-coverage --disable-sandbox; \
	else \
		swift test --filter "$(PROJECT_NAME)Tests.$(TEST_FILE)/$(METHOD)" $(SWIFT_BUILD_FLAGS) --enable-code-coverage --disable-sandbox; \
	fi

# ===========================================
# Coverage
# ===========================================

# Helper shell fragment that reliably discovers the profile + binary even on older toolchains
# Must be executed inside a recipe (can't run before tests)
find-prof-and-bin = \
    prof=$$(find .build -type f -name default.profdata -print -quit); \
    bin=$$(find .build -type d -name '*.xctest' -print -quit); \
    exec=$${bin}/Contents/MacOS/$$(basename $$bin .xctest); \
    echo "$$prof $$exec"

# Default coverage source pattern (can be overridden by individual projects)
COVERAGE_SOURCE_PATTERN ?= (Apuntika/Packages/$(PROJECT_NAME)/Sources/$(PROJECT_NAME)|$(PROJECT_NAME)/Sources/$(PROJECT_NAME))

# @help:coverage: Generate and display code coverage summary
.PHONY: coverage
coverage: build-and-test
	@echo "$(BLUE)Generating coverage summary...$(RESET)"
	@mkdir -p .build
	@read prof exec <<< "$$( $(call find-prof-and-bin) )"; \
	llvm-cov report -instr-profile $$prof $$exec | grep -E '$(COVERAGE_SOURCE_PATTERN)' | tee coverage-summary.txt

# @help:coverage-quiet: Generate code coverage summary silently and display results
.PHONY: coverage-quiet
coverage-quiet:
	@rm -f coverage-summary.txt
	@$(MAKE) build-and-test >/dev/null 2>&1
	@read prof exec <<< "$$( $(call find-prof-and-bin) )"; \
	llvm-cov report -instr-profile $$prof $$exec | grep -E '$(COVERAGE_SOURCE_PATTERN)' > coverage-summary.txt 2>/dev/null
	@cat coverage-summary.txt

# @help:coverage-lcov: Generate LCOV file at coverage/coverage.lcov
.PHONY: coverage-lcov lcov
coverage-lcov lcov: build-and-test
	@echo "$(BLUE)Exporting LCOV to coverage/coverage.lcov...$(RESET)"
	@mkdir -p coverage; \
	read prof exec <<< "$$( $(call find-prof-and-bin) )"; \
	llvm-cov export -format=lcov -instr-profile $$prof $$exec > coverage/coverage.lcov

# @help:coverage-html: Generate HTML coverage report and open in browser
.PHONY: coverage-html html
coverage-html html: coverage-lcov
	@echo "$(BLUE)Generating HTML report...$(RESET)"
	@genhtml coverage/coverage.lcov --output-directory coverage/html
	@echo "$(BLUE)Opening coverage/html/index.html$(RESET)"
	@open coverage/html/index.html

# @help:coverage-file: Show coverage for a specific file (usage: make coverage-file FILE=path/to/File.swift)
.PHONY: coverage-file file-coverage
coverage-file file-coverage:
	@if [ -z "$(FILE)" ]; then \
		echo "Error: specify FILE=<path/to/File.swift>"; exit 1; fi
	@echo "$(BLUE)Coverage for $(FILE)...$(RESET)"
	@read prof exec <<< "$$( $(call find-prof-and-bin) )"; \
	llvm-cov show -instr-profile $$prof $$exec --sources "$(FILE)"
	@echo "$(BLUE)Scroll up to see the execution count for each line in $(FILE)$(RESET)"
	@echo "$(BLUE)Lines without numbers represent non executable code, like declarations, parameter lists, whitespace, etc$(RESET)"
