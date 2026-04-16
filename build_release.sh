#!/bin/bash
# KnockApp - Production Build Script (Reverted to standard ZIP) 🥁🚀

# Mirroring the FileLister infrastructure for consistency in the Single Use Apps suite.
# Reverting to simple zip -r and default xcodebuild to match working FileLister bundle.

APP_NAME="KnockApp"
BUILD_DIR="./build"
DIST_DIR="./Dist"

echo "🚀 Starting Production Build for $APP_NAME..."

# 1. Cleanup
rm -rf "$BUILD_DIR"
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# 2. Build via xcodebuild
echo "📦 Compiling project..."
xcodebuild -scheme "$APP_NAME" \
           -configuration Release \
           -derivedDataPath "$BUILD_DIR" \
           build | grep -A 5 "error:"

# 3. Locate and Package the .app
SOURCE_APP="$BUILD_DIR/Build/Products/Release/$APP_NAME.app"

if [ -d "$SOURCE_APP" ]; then
    echo "✅ Build Successful!"
    
    echo "📂 Copying app to $DIST_DIR..."
    cp -R "$SOURCE_APP" "$DIST_DIR/"
    
    # Create the ZIP for distribution using standard zip -r (matching FileLister)
    echo "🗜️  Creating distribution bundle with zip..."
    cd "$DIST_DIR"
    zip -r "knockapp.zip" "$APP_NAME.app"
    cd ..
    
    echo "--------------------------------------------------"
    echo "🎉 READY FOR RELEASE!"
    echo "Location: $DIST_DIR/$APP_NAME.app"
    echo "Zip for GitHub: $DIST_DIR/$APP_NAME-macOS.zip"
    echo "--------------------------------------------------"
else
    echo "❌ Error: Could not find the built .app. Please check if the Scheme name is '$APP_NAME'."
fi
