# ===========================================
# Generate DocC for packages
# ===========================================

# This is imported by package.mk

# Creates raw DocC HTML without styling or renderer
# @help:docs-build: Generate DocC documentation archive to .docc-build/
.PHONY: docs-build docc-archive
docs-build docc-archive:
	@echo "$(BLUE)Generating DocC documentation archive...$(RESET)"
	swift package \
		--allow-writing-to-directory ./.docc-build \
		generate-documentation \
		--target $(PROJECT_NAME) \
		--output-path ./.docc-build \
		--transform-for-static-hosting \
		--hosting-base-path $(PROJECT_NAME) \
		--disable-indexing
	@echo "$(BLUE)Documentation archive created at ./.docc-build$(RESET)"

# Define a function to check if swift-docc-render/dist exists
define check_swift_docc_render
	@if [ ! -d "../swift-docc-render/dist" ]; then \
		echo "$(RED)Error: ../swift-docc-render/dist directory not found$(RESET)"; \
		echo "$(BLUE)Please run the following commands to set up swift-docc-render:$(RESET)"; \
		echo ""; \
		echo "cd .."; \
		echo "git clone https://github.com/swiftlang/swift-docc-render.git"; \
		echo "cd swift-docc-render"; \
		echo "mise install node@18.19.1"; \
		echo "mise use node@18.19.1"; \
		echo "npm install"; \
		echo "npm run build"; \
		echo ""; \
		echo "# go back to the project"; \
		echo "cd ../$(PROJECT_NAME)"; \
		echo ""; \
		exit 1; \
	fi
endef

# Creates the raw DocC and copies render assets
# @help:docs-render: Build HTML docs ready to be hosted
.PHONY: docs-render docc-rendered
docs-render docc-rendered: docs-build
	@echo "CWD is: $(shell pwd)"
	$(call check_swift_docc_render)
	@echo "$(BLUE)Copying swift-docc-render assets into .docc-build...$(RESET)"
	cp -a ../swift-docc-render/dist/. .docc-build/
	@echo "$(BLUE)Documentation ready for static hosting with swift-docc-render$(RESET)"

# Show styled docs on a local server
# @help:docs-preview: Serve documentation locally in a web browser
.PHONY: docs-preview preview-docs
docs-preview preview-docs:
	@echo "$(BLUE)Generating DocC docs for local preview...$(RESET)"
	swift package \
		--allow-writing-to-directory .docc-build \
		generate-documentation \
		--target $(PROJECT_NAME) \
		--output-path .docc-build \
		--disable-indexing
	$(call check_swift_docc_render)
	@echo "$(BLUE)Copying swift-docc-render assets into .docc-build...$(RESET)"
	cp -a ../swift-docc-render/dist/. .docc-build/
	@echo "$(BLUE)Opening documentation in your default browser...$(RESET)"
	@open "http://localhost:8000/documentation/$(shell echo $(PROJECT_NAME) | tr '[:upper:]' '[:lower:]')"
	cd .docc-build && python3 -m http.server

# @help:docs-clean: Clean and regenerate documentation preview
.PHONY: docs-clean docc-preview-clean
docs-clean docc-preview-clean:
	rm -rf .docc-build
	make docs-preview

# Deploy documentation to GitHub Pages
# @help:docs-deploy: Deploy documentation to GitHub Pages
.PHONY: docs-deploy deploy-docs
docs-deploy deploy-docs: docs-render
	@echo "$(BLUE)Deploying DocC to GitHub Pages...$(RESET)"
	ghp-import -n -p -f .docc-build
