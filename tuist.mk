
# Tuist-related targets

# @help:generate: Generate Xcode project files
.PHONY: generate
generate:
	@echo "$(BLUE)Removing Xcode project files...$(RESET)"
	@rm -rf $(PROJECT_NAME).xcodeproj $(PROJECT_NAME).xcworkspace
	@echo "$(GREEN)Xcode project files removed successfully$(RESET)"
	@echo "$(BLUE)Generating new Xcode project files with Tuist...$(RESET)"
	@tuist generate --no-open
	@echo "$(GREEN)Xcode project files generated successfully$(RESET)"

# @help:generate-cached: Generate Xcode project files using cached dependencies
.PHONY: generate-cached
generate-cached:
	@echo "$(BLUE)Removing Xcode project files...$(RESET)"
	@rm -rf $(PROJECT_NAME).xcodeproj $(PROJECT_NAME).xcworkspace
	@echo "$(GREEN)Xcode project files removed successfully$(RESET)"
	@echo "$(BLUE)Generating new Xcode project files with cached dependencies...$(RESET)"
	@USE_CACHED_DEPENDENCIES=1 tuist generate --no-open
	@echo "$(GREEN)Xcode project files generated successfully with cached dependencies$(RESET)"

# @help:tuist-clean: Clean Tuist artifacts and dependencies
.PHONY: tuist-clean
tuist-clean:
	@echo "$(BLUE)Cleaning Tuist artifacts...$(RESET)"
	@tuist clean
	@echo "$(GREEN)Tuist artifacts cleaned successfully$(RESET)"

# @help:tuist-install: Install Tuist dependencies
.PHONY: tuist-install
tuist-install:
	@echo "$(BLUE)Installing Tuist dependencies...$(RESET)"
	@tuist install
	@echo "$(GREEN)Dependencies installed successfully$(RESET)"

# @help:tuist-cache: Cache all dependencies as binary frameworks
.PHONY: tuist-cache
tuist-cache:
	@echo "$(BLUE)Caching dependencies as binary frameworks...$(RESET)"
	@tuist cache --external-only
	@echo "$(GREEN)Dependencies cached successfully$(RESET)"

# @help:tuist-cache-print: Print hashes of cacheable frameworks
.PHONY: tuist-cache-print
tuist-cache-print:
	@echo "$(BLUE)Printing cacheable framework hashes...$(RESET)"
	@tuist cache --print-hashes

# @help:tuist-cache-warm: Warm the cache for both Debug and Release configurations
.PHONY: tuist-cache-warm
tuist-cache-warm:
	@echo "$(BLUE)Warming cache for Debug configuration...$(RESET)"
	@tuist cache --external-only --configuration Debug
	@echo "$(BLUE)Warming cache for Release configuration...$(RESET)"
	@tuist cache --external-only --configuration Release
	@echo "$(GREEN)Cache warmed for all configurations$(RESET)"

# @help:tuist-update: Update dependencies and regenerate project
.PHONY: tuist-update
tuist-update: tuist-clean tuist-install generate
	@echo "$(GREEN)Dependencies updated and project regenerated$(RESET)"

# @help:tuist-update-cache: Update dependencies, regenerate project, and rebuild cache
.PHONY: tuist-update-cache
tuist-update-cache: tuist-clean tuist-install generate tuist-cache-warm
	@echo "$(GREEN)Dependencies updated, project regenerated, and cache rebuilt$(RESET)"

# @help:generate-clean: Clean, install dependencies, and generate project
.PHONY: generate-clean
generate-clean: tuist-clean tuist-install generate
	@echo "$(GREEN)Clean generation completed$(RESET)"

# @help:generate-clean-cached: Clean, install dependencies, cache, and generate with cached dependencies
.PHONY: generate-clean-cached
generate-clean-cached: tuist-clean tuist-install tuist-cache-warm generate-cached
	@echo "$(GREEN)Clean generation with cached dependencies completed$(RESET)"

# @help:tuist-info: Show Tuist environment information
.PHONY: tuist-info
tuist-info:
	@echo "$(BLUE)Tuist Environment Information:$(RESET)"
	@echo "$(YELLOW)Tuist Version:$(RESET)"
	@tuist version
	@echo ""
	@echo "$(YELLOW)Environment Variables:$(RESET)"
	@echo "USE_CACHED_DEPENDENCIES: $${USE_CACHED_DEPENDENCIES:-not set}"
	@echo ""
	@if [ -d ".tuist-cache" ] || [ -d ".tuist/Cache" ]; then \
		echo "$(YELLOW)Cache Status:$(RESET)"; \
		echo "Cache directory exists"; \
		if [ -d ".tuist-cache" ]; then \
			echo "Cache location: .tuist-cache"; \
		else \
			echo "Cache location: .tuist/Cache"; \
		fi; \
	else \
		echo "$(YELLOW)Cache Status:$(RESET)"; \
		echo "No cache directory found"; \
	fi
