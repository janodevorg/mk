
# Auto-generated help target
# @help:help: Show this help message
.PHONY: help
help:
	@echo "$(BLUE)===== $(PROJECT_NAME) Makefile Help =====$(RESET)"
	@echo ""
	@echo "$(BLUE)AVAILABLE COMMANDS:$(RESET)"
	@awk -F":" '/^# @help:[a-zA-Z0-9_-]+:/ { \
		gsub(/^# @help:/, ""); \
		printf "  make %-20s %s\n", $$1, substr($$0, index($$0, $$2)); \
	}' $(MAKEFILE_LIST) | sort
	@echo ""
	@echo "$(BLUE)CURRENT CONFIGURATION:$(RESET)"
	@echo "  Project: $(PROJECT_NAME)"
	@echo ""
