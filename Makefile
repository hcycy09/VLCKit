# Makefile for building VLCKit xcframework for all Apple platforms
# Supports: iOS, iOS Simulator, macOS, tvOS, tvOS Simulator, visionOS, visionOS Simulator

# Configuration
VLCKIT_REPO = https://code.videolan.org/videolan/VLCKit.git
VLCKIT_DIR = VLCKit-Source
BUILD_DIR = build

# Version (update this for each release)
VERSION ?= 1.0.0

# Framework naming with version
XCFRAMEWORK_NAME = VLCKit.xcframework
XCFRAMEWORK_PATH = $(BUILD_DIR)/$(XCFRAMEWORK_NAME)
PACKAGE_NAME = VLCKit-$(VERSION).xcframework.zip
CHECKSUM_FILE = $(BUILD_DIR)/VLCKit-$(VERSION).sha256

# Build script path (relative to VLCKit source directory)
COMPILE_SCRIPT = compileAndBuildVLCKit.sh

.PHONY: all clean clone build-ios build-macos build-tvos build-visionos build-all merge-xcframeworks package

all: clone merge-xcframeworks

# Clone VLCKit repository
clone:
	@echo "📦 Cloning VLCKit repository..."
	@if [ -d "$(VLCKIT_DIR)" ]; then \
		echo "⚠️  VLCKit directory already exists. Removing..."; \
		rm -rf $(VLCKIT_DIR); \
	fi
	git clone $(VLCKIT_REPO) $(VLCKIT_DIR)
	@echo "✅ Clone complete"

# Build iOS (device)
build-ios: 
	@echo "🔨 Building VLCKit for iOS (device)..."
	cd $(VLCKIT_DIR) && ./$(COMPILE_SCRIPT) -f -r -a all
	cd ..
	@echo "✅ iOS build complete"

# Build macOS
build-macos: 
	@echo "🔨 Building VLCKit for macOS..."
	cd $(VLCKIT_DIR) && ./$(COMPILE_SCRIPT) -x -r -a all
	cd ..
	@echo "✅ macOS build complete"

# Build tvOS (device)
build-tvos: 
	@echo "🔨 Building VLCKit for tvOS (device)..."
	cd $(VLCKIT_DIR) && ./$(COMPILE_SCRIPT) -f -r -t -a all
	cd ..
	@echo "✅ tvOS build complete"

# Build visionOS (device)
build-visionos: 
	@echo "🔨 Building VLCKit for visionOS (device)..."
	cd $(VLCKIT_DIR) && ./$(COMPILE_SCRIPT) -f -r -i -a all
	cd ..
	@echo "✅ visionOS build complete"

# Build all platforms
build-all: build-ios build-macos build-tvos build-visionos
	@echo "✅ All platforms built successfully"


# Merge platform-specific xcframeworks into one unified xcframework
merge-xcframeworks: 
	@echo "🔄 Merging platform-specific xcframeworks..."
	@mkdir -p $(BUILD_DIR)
	@rm -rf $(XCFRAMEWORK_PATH)
	@# Collect all framework paths from each platform's xcframework
	@FRAMEWORK_ARGS=""; \
	for platform in iOS macOS tvOS xrOS; do \
		PLATFORM_XCFW="$(VLCKIT_DIR)/build/$$platform/VLCKit.xcframework"; \
		if [ -d "$$PLATFORM_XCFW" ]; then \
			echo "  Found $$platform xcframework"; \
			for variant in $$PLATFORM_XCFW/*-*; do \
				if [ -d "$$variant" ] && [ -d "$$variant/VLCKit.framework" ]; then \
					FRAMEWORK_ARGS="$$FRAMEWORK_ARGS -framework $$variant/VLCKit.framework"; \
				fi; \
			done; \
		fi; \
	done; \
	if [ -z "$$FRAMEWORK_ARGS" ]; then \
		echo "❌ Error: No platform xcframeworks found in $(VLCKIT_DIR)/build/"; \
		echo "   Expected folders: iOS, macOS, tvOS, xrOS"; \
		exit 1; \
	fi; \
	echo "🔨 Creating unified xcframework..."; \
	xcodebuild -create-xcframework $$FRAMEWORK_ARGS -output $(XCFRAMEWORK_PATH)
	@echo "✅ Unified XCFramework created at $(XCFRAMEWORK_PATH)"
	@echo "📊 Framework size:"
	@du -sh $(XCFRAMEWORK_PATH)
	@echo ""
	@echo "Version: $(VERSION)"
	@echo ""
	@echo "📋 Included platforms:"
	@plutil -p $(XCFRAMEWORK_PATH)/Info.plist | grep -A2 "SupportedPlatform" | grep '"' | sort -u
	@echo ""
	@echo "📦 Creating distributable package (version $(VERSION))..."
	@cd $(BUILD_DIR) && zip -r $(PACKAGE_NAME) $(XCFRAMEWORK_NAME)
	@echo "✅ Package created at $(BUILD_DIR)/$(PACKAGE_NAME)"
	@echo ""
	@echo "📊 Package size:"
	@du -sh $(BUILD_DIR)/$(PACKAGE_NAME)
	@echo ""
	@echo "🔐 Generating SHA256 checksum..."
	@shasum -a 256 $(BUILD_DIR)/$(PACKAGE_NAME) | tee $(CHECKSUM_FILE)
	@echo ""
	@echo "✅ Checksum saved to $(CHECKSUM_FILE)"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "🎉 Build Complete!"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Version:   $(VERSION)"
	@echo "Package:   $(BUILD_DIR)/$(PACKAGE_NAME)"
	@echo "Checksum:  $(CHECKSUM_FILE)"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create a distributable zip with version (alias for merge-xcframeworks)
package: merge-xcframeworks

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf $(VLCKIT_DIR)
	rm -rf $(BUILD_DIR)
	@echo "✅ Clean complete"

# Help target
help:
	@echo "VLCKit XCFramework Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  all                  - Build xcframework for all platforms (default)"
	@echo "  clone                - Clone VLCKit repository"
	@echo "  build-ios            - Build for iOS (device + simulator)"
	@echo "  build-macos          - Build for macOS"
	@echo "  build-tvos           - Build for tvOS (device + simulator)"
	@echo "  build-visionos       - Build for visionOS (device + simulator)"
	@echo "  build-all            - Build all platforms"
	@echo "  merge-xcframeworks   - Merge platform xcframeworks into one with zip and checksum"
	@echo "  package              - Same as merge-xcframeworks"
	@echo "  clean                - Remove all build artifacts"
	@echo "  help                 - Show this help message"
	@echo ""
	@echo "Example usage:"
	@echo "  make                           - Build all platforms and create package (default)"
	@echo "  make merge-xcframeworks        - Merge iOS/macOS/tvOS/xrOS xcframeworks into one"
	@echo "  make package                   - Same as merge-xcframeworks"
	@echo "  make VERSION=3.6.0             - Build with specific version number"
	@echo "  make clean                     - Clean all build artifacts"
	@echo ""
	@echo "Current version: $(VERSION)"
