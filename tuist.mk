
# Target to regenerate Xcode project files using Tuist
# @help:generate: Generate Xcode project files
.PHONY: generate
generate:
	@echo "$(BLUE)Removing Xcode project files...$(RESET)"
	@rm -rf $(PROJECT_NAME).xcodeproj $(PROJECT_NAME).xcworkspace
	@echo "$(GREEN)Xcode project files removed successfully$(RESET)"
	@echo "$(BLUE)Generating new Xcode project files with Tuist...$(RESET)"
	@tuist generate --no-open
	@echo "$(GREEN)Xcode project files generated successfully$(RESET)"
