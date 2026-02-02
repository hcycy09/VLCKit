# VLCKit XCFramework Builder

Automated build system for creating a universal VLCKit XCFramework supporting all Apple platforms.

## Description

This project provides a Makefile-based build system that:
- Clones the official VLCKit repository
- Builds production (release) versions for all Apple platforms
- Creates a universal XCFramework
- Generates versioned packages with SHA256 checksums
- Supports Swift Package Manager (SPM) integration

## Supported Platforms

- **iOS** (arm64)
- **iOS Simulator** (x86_64, arm64)
- **macOS** (x86_64, arm64)
- **tvOS** (arm64)
- **tvOS Simulator** (x86_64, arm64)
- **visionOS** (arm64)
- **visionOS Simulator** (x86_64, arm64)

## Requirements

- macOS with Xcode installed
- Command Line Tools for Xcode
- Git
- Make (pre-installed on macOS)
- Sufficient disk space (~10-20GB for builds)
- Internet connection for cloning VLCKit repository

## Quick Start

### Build Everything (Default)

```bash
make build-all
```

This will:
1. Clone the VLCKit repository
2. Build for all platforms (production/release mode)
3. Create a universal XCFramework

### Build with Packaging

```bash
make package VERSION=3.7.0
```

This creates:
- Universal XCFramework
- Versioned zip file (`VLCKit-3.7.0.xcframework.zip`)
- SHA256 checksum file (`VLCKit-3.7.0.sha256`)


## Available Commands

| Command | Description |
|---------|-------------|
| `make` or `make all` | Build XCFramework for all platforms |
| `make package` | Build and create distributable package |
| `make clean` | Remove all build artifacts and cloned repository |
| `make help` | Show all available commands |
| `make build-ios` | Build only for iOS devices |
| `make build-ios-simulator` | Build only for iOS Simulator |
| `make build-macos` | Build only for macOS |
| `make build-tvos` | Build only for tvOS devices |
| `make build-tvos-simulator` | Build only for tvOS Simulator |
| `make build-visionos` | Build only for visionOS devices |
| `make build-visionos-simulator` | Build only for visionOS Simulator |

## Version Management

The default version is `1.0.0`. You can specify a custom version using the `VERSION` parameter:

```bash
# Build with version 3.6.0
make package VERSION=3.6.0

# Build with semantic versioning
make package VERSION=4.0.0-beta.1
```

The version number is embedded in:
- Output package filename: `VLCKit-{VERSION}.xcframework.zip`
- Checksum filename: `VLCKit-{VERSION}.sha256`
- Build logs and output messages

## Output Structure

After running `make package`, you'll find:

```
build/
├── VLCKit.xcframework/          # Universal XCFramework
├── VLCKit-1.0.0.xcframework.zip # Distributable package
└── VLCKit-1.0.0.sha256          # SHA256 checksum
```

## Build Process Details

### What Happens During Build

1. **Clone**: Downloads VLCKit from official repository
2. **Build**: Compiles for each platform using `compileAndBuildVLCKit.sh` with:
   - Release mode (`-r` flag for production builds)
   - Architecture-specific flags (`-a arm64` or `-a "x86_64 arm64"`)
   - Platform-specific SDK targets (`-t iphoneos`, `-t macosx`, etc.)
3. **Merge**: Combines all platform frameworks into single XCFramework
4. **Package**: Creates zip and generates checksum

### Build Flags

All builds use the `-r` flag for **production/release mode** (not debug).

Example build command for iOS:
```bash
./compileAndBuildVLCKit.sh -a arm64 -t iphoneos -r
```

## Usage Examples

### Example 1: First-time Build

```bash
# Clone and build everything
make package VERSION=3.6.0

# View checksum
cat build/VLCKit-3.6.0.sha256
```

### Example 2: Clean Rebuild

```bash
# Remove all previous builds
make clean

# Build with new version
make package VERSION=3.6.1
```

### Example 3: Build Single Platform (Testing)

```bash
# Build only iOS for testing
make clone
make build-ios
```

## Troubleshooting

### Build Fails with "command not found"

Ensure Xcode Command Line Tools are installed:
```bash
xcode-select --install
```

### Insufficient Disk Space

VLCKit builds require significant disk space. Clean up before building:
```bash
make clean
```

### Build Script Not Found

If `compileAndBuildVLCKit.sh` is not found, verify it exists in the VLCKit repository. The script path is configured in the Makefile:
```makefile
COMPILE_SCRIPT = compileAndBuildVLCKit.sh
```

### Framework Paths Incorrect

If frameworks are not found after building, check the output paths in the Makefile match your VLCKit version. These variables may need adjustment:
```makefile
IOS_FRAMEWORK = $(VLCKIT_DIR)/build/MobileVLCKit.framework
MACOS_FRAMEWORK = $(VLCKIT_DIR)/build/VLCKit.framework
# etc.
```

### visionOS Build Issues

visionOS support requires Xcode 15+ with visionOS SDK. If you encounter issues:
- Verify Xcode version: `xcodebuild -version`
- Check available SDKs: `xcodebuild -showsdks`
- Update SDK names in Makefile if needed (`xros`, `xrsimulator`)

## Integration with Swift Package Manager

After building, you can use the XCFramework with SPM by:

1. Upload the zip file to a release or hosting service
2. Get the URL and SHA256 checksum
3. Update your `Package.swift`:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "MyApp", targets: ["MyApp"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MyApp",
            dependencies: ["VLCKit"]
        ),
        .binaryTarget(
            name: "VLCKit",
            url: "https://your-host.com/VLCKit-3.6.0.xcframework.zip",
            checksum: "your-sha256-checksum-here"
        )
    ]
)
```

## Clean Up

Remove all build artifacts and cloned repository:

```bash
make clean
```

This removes:
- `VLCKit-Source/` (cloned repository)
- `build/` (all build outputs)

## Git Ignore

The following files/directories are ignored by git (see `.gitignore`):
- `VLCKit-Source/` - Cloned repository
- `build/` - Build outputs
- `*.xcframework` - Framework bundles
- `*.zip` - Packages
- `*.sha256` - Checksums
- `.DS_Store` - macOS metadata

## License

This build system is provided as-is. VLCKit itself is licensed under LGPL/GPL. Please review VLCKit's license before distribution.

## Contributing

To contribute improvements:
1. Fork this repository
2. Make your changes
3. Test the build process
4. Submit a pull request

## Support

For issues related to:
- **This build system**: Open an issue in this repository
- **VLCKit itself**: Visit [VideoLAN's VLCKit repository](https://code.videolan.org/videolan/VLCKit)
- **VLC functionality**: See [VLC documentation](https://www.videolan.org/)
