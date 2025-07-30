# ===========================================
# Generate DocC for packages
# ===========================================

# This is imported by xcode.mk

DOCC_PATH := xcrun docc

# Creates raw DocC HTML without styling or renderer
# @help:docc-archive: Generate DocC documentation archive for Xcode projects
.PHONY: docc-archive
docc-archive:
	@echo "$(BLUE)Generating DocC documentation archive...$(RESET)"
	@echo "$(YELLOW)Executing: xcodebuild docbuild -scheme $(PROJECT_NAME) -destination 'generic/platform=iOS' -derivedDataPath ./DerivedData$(RESET)"
	xcodebuild docbuild \
		-scheme $(PROJECT_NAME) \
		-destination 'generic/platform=iOS' \
		-derivedDataPath ./DerivedData
	
	@echo "$(BLUE)Using DocC archive...$(RESET)"
	mkdir -p ./.docc-build
	
	$(eval DOCC_ARCHIVE := ./DerivedData/Build/Products/Debug-iphoneos/$(PROJECT_NAME).doccarchive)
	@echo "DocC archive location: $(DOCC_ARCHIVE)"
	
	@if [ ! -d "$(DOCC_ARCHIVE)" ]; then \
		echo "$(RED)Error: DocC archive not found at expected location: $(DOCC_ARCHIVE)$(RESET)"; \
		echo "Searching for alternative locations:"; \
		find ./DerivedData -name "*.doccarchive" -type d; \
		exit 1; \
	fi
	
	@echo "$(BLUE)Processing archive for static hosting...$(RESET)"
	$(DOCC_PATH) process-archive transform-for-static-hosting \
		"$(DOCC_ARCHIVE)" \
		--output-path ./.docc-build \
		--hosting-base-path /
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
.PHONY: docc-rendered
docc-rendered: docc-archive
	@echo "CWD is: $(shell pwd)"
	$(call check_swift_docc_render)
	@echo "$(BLUE)Copying swift-docc-render assets into .docc-build...$(RESET)"
	cp -a ../swift-docc-render/dist/. .docc-build/
	@echo "$(BLUE)Documentation ready for static hosting with swift-docc-render$(RESET)"

# Show styled docs on a local server
.PHONY: preview-docs
preview-docs:
	@echo "$(BLUE)Generating DocC docs for local preview...$(RESET)"
	@echo "$(YELLOW)Executing: xcodebuild docbuild -scheme $(PROJECT_NAME) -destination 'generic/platform=iOS' -derivedDataPath ./DerivedData$(RESET)"
	xcodebuild docbuild \
		-scheme $(PROJECT_NAME) \
		-destination 'generic/platform=iOS' \
		-derivedDataPath ./DerivedData
	
	mkdir -p ./.docc-build
	$(eval DOCC_ARCHIVE := ./DerivedData/Build/Products/Debug-iphoneos/$(PROJECT_NAME).doccarchive)
	@echo "DocC archive location: $(DOCC_ARCHIVE)"
	
	@if [ ! -d "$(DOCC_ARCHIVE)" ]; then \
		echo "$(RED)Error: DocC archive not found at expected location: $(DOCC_ARCHIVE)$(RESET)"; \
		echo "Searching for alternative locations:"; \
		find ./DerivedData -name "*.doccarchive" -type d; \
		exit 1; \
	fi
	
	$(call check_swift_docc_render)
	@echo "$(BLUE)Processing DocC archive for local preview...$(RESET)"
	$(DOCC_PATH) process-archive transform-for-static-hosting \
		"$(DOCC_ARCHIVE)" \
		--output-path ./.docc-build \
		--hosting-base-path /
	
	@echo "$(BLUE)Copying swift-docc-render assets into .docc-build...$(RESET)"
	cp -a ../swift-docc-render/dist/. .docc-build/
	
	@echo "$(BLUE)Starting local server...$(RESET)"
	@echo "$(BLUE)Open your browser to: http://localhost:8000/documentation/$(shell echo $(PROJECT_NAME) | tr '[:upper:]' '[:lower:]')$(RESET)"
	cd .docc-build && python3 -m http.server 8000
	$(call check_swift_docc_render)
	@echo "$(BLUE)Copying swift-docc-render assets into .docc-build...$(RESET)"
	cp -a ../swift-docc-render/dist/. .docc-build/
	$(DOCC_PATH) preview "$(LATEST_BUILD)" \
		--hosting-base-path $(PROJECT_NAME) \
		--port 8000
	@echo "$(BLUE)Opening documentation in your default browser...$(RESET)"
	@open "http://localhost:8000/documentation/$(shell echo $(PROJECT_NAME) | tr '[:upper:]' '[:lower:]')"

# @help:docc-preview-clean: Clean and regenerate documentation preview for Xcode projects
.PHONY: docc-preview-clean
docc-preview-clean:
	rm -rf .docc-build
	rm -rf ./DerivedData
	make preview-docs

# Deploy documentation to GitHub Pages
.PHONY: deploy-docs
deploy-docs: docc-rendered
	@echo "$(BLUE)Deploying DocC to GitHub Pages...$(RESET)"
	ghp-import -n -p -f .docc-build
