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

# Framework paths after building
IOS_FRAMEWORK = $(VLCKIT_DIR)/build/MobileVLCKit.framework
IOS_SIM_FRAMEWORK = $(VLCKIT_DIR)/build/MobileVLCKit-Simulator.framework
MACOS_FRAMEWORK = $(VLCKIT_DIR)/build/VLCKit.framework
TVOS_FRAMEWORK = $(VLCKIT_DIR)/build/TVVLCKit.framework
TVOS_SIM_FRAMEWORK = $(VLCKIT_DIR)/build/TVVLCKit-Simulator.framework
VISIONOS_FRAMEWORK = $(VLCKIT_DIR)/build/XRVLCKit.framework
VISIONOS_SIM_FRAMEWORK = $(VLCKIT_DIR)/build/XRVLCKit-Simulator.framework

.PHONY: all clean clone build-ios build-ios-simulator build-macos build-tvos build-tvos-simulator build-visionos build-visionos-simulator xcframework

all: xcframework

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
build-ios: clone
	@echo "🔨 Building VLCKit for iOS (device)..."
	cd $(VLCKIT_DIR) && ./$(COMPILE_SCRIPT) -a arm64 -t iphoneos -r
	@echo "✅ iOS build complete"

# Build iOS Simulator
build-ios-simulator: clone
	@echo "🔨 Building VLCKit for iOS Simulator..."
	cd $(VLCKIT_DIR) && ./$(COMPILE_SCRIPT) -a "x86_64 arm64" -t iphonesimulator -r
	@echo "✅ iOS Simulator build complete"

# Build macOS
build-macos: clone
	@echo "🔨 Building VLCKit for macOS..."
	cd $(VLCKIT_DIR) && ./$(COMPILE_SCRIPT) -a "x86_64 arm64" -t macosx -r
	@echo "✅ macOS build complete"

# Build tvOS (device)
build-tvos: clone
	@echo "🔨 Building VLCKit for tvOS (device)..."
	cd $(VLCKIT_DIR) && ./$(COMPILE_SCRIPT) -a arm64 -t appletvos -r
	@echo "✅ tvOS build complete"

# Build tvOS Simulator
build-tvos-simulator: clone
	@echo "🔨 Building VLCKit for tvOS Simulator..."
	cd $(VLCKIT_DIR) && ./$(COMPILE_SCRIPT) -a "x86_64 arm64" -t appletvsimulator -r
	@echo "✅ tvOS Simulator build complete"

# Build visionOS (device)
build-visionos: clone
	@echo "🔨 Building VLCKit for visionOS (device)..."
	cd $(VLCKIT_DIR) && ./$(COMPILE_SCRIPT) -a arm64 -t xros -r
	@echo "✅ visionOS build complete"

# Build visionOS Simulator
build-visionos-simulator: clone
	@echo "🔨 Building VLCKit for visionOS Simulator..."
	cd $(VLCKIT_DIR) && ./$(COMPILE_SCRIPT) -a "x86_64 arm64" -t xrsimulator -r
	@echo "✅ visionOS Simulator build complete"

# Build all platforms
build-all: build-ios build-ios-simulator build-macos build-tvos build-tvos-simulator build-visionos build-visionos-simulator
	@echo "✅ All platforms built successfully"

# Create xcframework
xcframework: build-all
	@echo "📦 Creating universal xcframework (version $(VERSION))..."
	@mkdir -p $(BUILD_DIR)
	@rm -rf $(XCFRAMEWORK_PATH)
	xcodebuild -create-xcframework \
		-framework $(IOS_FRAMEWORK) \
		-framework $(IOS_SIM_FRAMEWORK) \
		-framework $(MACOS_FRAMEWORK) \
		-framework $(TVOS_FRAMEWORK) \
		-framework $(TVOS_SIM_FRAMEWORK) \
		-framework $(VISIONOS_FRAMEWORK) \
		-framework $(VISIONOS_SIM_FRAMEWORK) \
		-output $(XCFRAMEWORK_PATH)
	@echo "✅ XCFramework created at $(XCFRAMEWORK_PATH)"
	@echo "📊 Framework size:"
	@du -sh $(XCFRAMEWORK_PATH)
	@echo ""
	@echo "Version: $(VERSION)"

# Create a distributable zip with version
package: xcframework
	@echo "📦 Creating distributable package (version $(VERSION))..."
	cd $(BUILD_DIR) && zip -r $(PACKAGE_NAME) $(XCFRAMEWORK_NAME)
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
	@echo "  build-ios            - Build for iOS devices"
	@echo "  build-ios-simulator  - Build for iOS Simulator"
	@echo "  build-macos          - Build for macOS"
	@echo "  build-tvos           - Build for tvOS devices"
	@echo "  build-tvos-simulator - Build for tvOS Simulator"
	@echo "  build-visionos       - Build for visionOS devices"
	@echo "  build-visionos-simulator - Build for visionOS Simulator"
	@echo "  build-all            - Build all platforms"
	@echo "  xcframework          - Create universal xcframework"
	@echo "  package              - Create distributable zip with checksum"
	@echo "  clean                - Remove all build artifacts"
	@echo "  help                 - Show this help message"
	@echo ""
	@echo "Example usage:"
	@echo "  make                      - Build everything and create xcframework"
	@echo "  make package              - Build and create distributable package"
	@echo "  make package VERSION=3.6.0 - Build with specific version number"
	@echo "  make clean                - Clean all build artifacts"
	@echo ""
	@echo "Current version: $(VERSION)"
