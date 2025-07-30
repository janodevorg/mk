# ===========================================
# Coverage test - Shared utilities
# ===========================================

# This is imported by xcode.mk, package.mk
# Coverage targets are now defined in their respective project-specific files

# @help:results-bundle: Build tests and save results to TestRun.xcresult
.PHONY: results-bundle result-bundle
results-bundle result-bundle:
	@echo "$(BLUE)Building $(PROJECT_NAME) and producing $(RESULT_BUNDLE)…$(RESET)"
	@rm -rf $(RESULT_BUNDLE) || true
	@if [ -d "$(PROJECT_NAME).xcodeproj" ] || ls *.xcodeproj >/dev/null 2>&1; then \
		echo "$(YELLOW)Executing: xcodebuild -scheme $(PROJECT_NAME) -destination 'platform=iOS Simulator,name=$(SIMULATOR) $(SIMULATOR_OS)' -only-testing:$(PROJECT_NAME)Tests test -resultBundlePath $(RESULT_BUNDLE)$(RESET)"; \
		xcodebuild \
		-scheme $(PROJECT_NAME) \
		-destination 'platform=iOS Simulator,name=$(SIMULATOR) $(SIMULATOR_OS)' \
		-only-testing:$(PROJECT_NAME)Tests \
		test \
		-resultBundlePath $(RESULT_BUNDLE); \
	else \
		echo "$(YELLOW)Executing: xcodebuild -scheme $(PACKAGE_SCHEME) -destination 'platform=macOS' test -resultBundlePath $(RESULT_BUNDLE)$(RESET)"; \
		xcodebuild \
		-scheme $(PACKAGE_SCHEME) \
		-destination 'platform=macOS' \
		test \
		-resultBundlePath $(RESULT_BUNDLE); \
	fi

# @help:results-summary: Build tests and print a JSON test summary
.PHONY: results-summary summary
results-summary summary: results-bundle
	@echo "$(BLUE)Executive summary for $(RESULT_BUNDLE)…$(RESET)"
	@xcrun xcresulttool get test-results summary \
	    --path $(RESULT_BUNDLE) | jq .

# @help:results-brief: Build tests and print brief pass/fail statistics
.PHONY: results-brief summary-brief
results-brief summary-brief: results-bundle
	@xcrun xcresulttool get test-results summary \
	    --path $(RESULT_BUNDLE) | \
	    jq -r '"Result: \(.result)  │  Total: \(.totalTestCount)  │  Passed: \(.passedTests)  │  Failed: \(.failedTests)  │  Skipped: \(.skippedTests)"'

# @help:results-file: Build tests and save a JSON summary to summary.json
.PHONY: results-file summary-file
results-file summary-file: results-bundle
	@echo "$(BLUE)Saving executive summary to summary.json…$(RESET)"
	@xcrun xcresulttool get test-results summary \
	    --path $(RESULT_BUNDLE) > summary.json
	@echo "$(BLUE)summary.json created$(RESET)"

