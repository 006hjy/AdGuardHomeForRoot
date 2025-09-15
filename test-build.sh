#!/bin/bash
# test-build.sh - Script to test the build workflow locally

set -e

echo "=== AdGuardHome for Root - Local Build Test ==="
echo "This script simulates the GitHub workflow to test the build process locally."
echo ""

# Configuration
ARCH=${1:-arm64}
TEMP_DIR="temp_build_test"
OUTPUT_DIR="build_output"

if [ "$ARCH" != "arm64" ] && [ "$ARCH" != "armv7" ]; then
    echo "Usage: $0 [arm64|armv7]"
    echo "Default: arm64"
    exit 1
fi

echo "Building for architecture: $ARCH"
echo ""

# Clean up from previous runs
rm -rf "$TEMP_DIR" "$OUTPUT_DIR"

# Create directories
mkdir -p "$TEMP_DIR" "$OUTPUT_DIR"

# Get latest release info
echo "Fetching latest AdGuardHome release..."
RELEASE_JSON=$(curl -s -f "https://api.github.com/repos/AdguardTeam/AdGuardHome/releases" 2>/dev/null || echo "")

if [ -n "$RELEASE_JSON" ]; then
    TAG_NAME=$(echo "$RELEASE_JSON" | jq -r '.[0].tag_name' 2>/dev/null || echo "")
    if [ "$TAG_NAME" = "null" ] || [ -z "$TAG_NAME" ]; then
        TAG_NAME="v0.107.52"
        echo "Failed to parse API response, using fallback: $TAG_NAME"
    else
        echo "Latest release found: $TAG_NAME"
    fi
else
    TAG_NAME="v0.107.52"
    echo "API request failed, using fallback: $TAG_NAME"
fi

# Construct download URL
if [ "$ARCH" = "armv7" ]; then
    DOWNLOAD_URL="https://github.com/AdguardTeam/AdGuardHome/releases/download/${TAG_NAME}/AdGuardHome_linux_armv7.tar.gz"
else
    DOWNLOAD_URL="https://github.com/AdguardTeam/AdGuardHome/releases/download/${TAG_NAME}/AdGuardHome_linux_arm64.tar.gz"
fi

echo "Download URL: $DOWNLOAD_URL"
echo ""

# Download AdGuardHome
echo "Downloading AdGuardHome..."
FILENAME="AdGuardHome_linux_${ARCH}.tar.gz"
cd "$TEMP_DIR"

if curl -L -f -o "$FILENAME" "$DOWNLOAD_URL"; then
    echo "Download successful"
    
    # Verify file size
    FILESIZE=$(stat -c%s "$FILENAME")
    echo "Downloaded file size: $FILESIZE bytes"
    
    if [ "$FILESIZE" -lt 1000000 ]; then
        echo "Warning: File seems too small (less than 1MB)"
    fi
    
    # Extract
    echo "Extracting archive..."
    tar -xzf "$FILENAME"
    
    if [ -f "AdGuardHome/AdGuardHome" ]; then
        echo "Extraction successful"
        echo "Binary info:"
        ls -la AdGuardHome/AdGuardHome
        file AdGuardHome/AdGuardHome
        echo ""
        
        # Copy to src/bin
        cd ..
        echo "Copying binary to src/bin/..."
        cp "$TEMP_DIR/AdGuardHome/AdGuardHome" src/bin/
        chmod +x src/bin/AdGuardHome
        
        # Create package
        echo "Creating package..."
        cd src
        zip -r "../$OUTPUT_DIR/AdGuardHomeForRoot_${ARCH}_${TAG_NAME}.zip" .
        cd ..
        
        echo "Package created successfully:"
        ls -la "$OUTPUT_DIR/"
        
        echo ""
        echo "Package contents:"
        unzip -l "$OUTPUT_DIR/AdGuardHomeForRoot_${ARCH}_${TAG_NAME}.zip"
        
        # Clean up binary from src/bin
        rm src/bin/AdGuardHome
        
    else
        echo "Error: AdGuardHome binary not found after extraction"
        echo "Contents:"
        find . -type f
        exit 1
    fi
    
else
    echo "Download failed"
    exit 1
fi

# Clean up
cd ..
rm -rf "$TEMP_DIR"

echo ""
echo "=== Build test completed successfully ==="
echo "Output: $OUTPUT_DIR/AdGuardHomeForRoot_${ARCH}_${TAG_NAME}.zip"