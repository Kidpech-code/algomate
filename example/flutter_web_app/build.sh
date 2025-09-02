#!/bin/bash

# AlgoMate Flutter Web Demo - Build Script
# This script builds the Flutter web app for production deployment

echo "🚀 Building AlgoMate Flutter Web Demo..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if we're in the correct directory
if [[ ! -f "pubspec.yaml" ]]; then
    echo "❌ pubspec.yaml not found. Please run this script from the flutter_web_app directory."
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

# Build for web
echo "🌐 Building for web..."
flutter build web --release --web-renderer html --base-href "/algomate-demo/"

# Check if build was successful
if [[ $? -eq 0 ]]; then
    echo "✅ Build successful!"
    echo "📁 Output directory: build/web"
    echo ""
    echo "🌍 To deploy:"
    echo "  1. Copy the contents of build/web/ to your web server"
    echo "  2. Configure your web server to serve the files"
    echo "  3. Ensure proper MIME types are set for Dart/Flutter files"
    echo ""
    echo "🧪 To test locally:"
    echo "  cd build/web && python -m http.server 8080"
    echo "  Then visit: http://localhost:8080"
else
    echo "❌ Build failed!"
    exit 1
fi
