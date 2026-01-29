#!/bin/bash

# TidyVibes Structure Verification Script
# Run this to verify your files are in the correct locations

echo "🔍 Verifying TidyVibes project structure..."
echo ""

# Check if we're in the right directory
if [ ! -d "TidyVibes/TidyVibes" ]; then
    echo "❌ Error: Run this script from the TidyVibes project root directory"
    echo "   Current directory: $(pwd)"
    echo "   Expected: /path/to/Tidy/TidyVibes"
    exit 1
fi

cd TidyVibes/TidyVibes

# Count Swift files
SWIFT_COUNT=$(find . -name "*.swift" -type f | wc -l)
echo "📝 Swift files found: $SWIFT_COUNT"
if [ $SWIFT_COUNT -lt 20 ]; then
    echo "   ⚠️  Expected at least 20 .swift files"
fi

# Check for required files
echo ""
echo "✅ Checking required files:"

check_file() {
    if [ -f "$1" ]; then
        echo "   ✅ $1"
    else
        echo "   ❌ Missing: $1"
    fi
}

check_file "TidyVibesApp.swift"
check_file "Info.plist"
check_file "Resources/ikea_products.json"
check_file "Models/StorageSpace.swift"
check_file "Models/Item.swift"
check_file "Models/IKEAProduct.swift"
check_file "Models/Enums.swift"
check_file "Services/GPTService.swift"
check_file "Services/IKEADataService.swift"
check_file "Services/SpeechService.swift"
check_file "Services/SearchService.swift"
check_file "Services/LayoutEngine.swift"

# Check JSON validity
echo ""
echo "📊 Checking ikea_products.json validity:"
if [ -f "Resources/ikea_products.json" ]; then
    if command -v python3 &> /dev/null; then
        if python3 -m json.tool Resources/ikea_products.json > /dev/null 2>&1; then
            echo "   ✅ Valid JSON format"
            PRODUCT_COUNT=$(python3 -c "import json; f=open('Resources/ikea_products.json'); print(len(json.load(f)))")
            echo "   ✅ Contains $PRODUCT_COUNT IKEA products"
        else
            echo "   ❌ Invalid JSON format!"
        fi
    else
        echo "   ⚠️  Cannot verify (python3 not available)"
    fi
else
    echo "   ❌ File not found!"
fi

# List all Swift files
echo ""
echo "📂 Project structure:"
echo ""
tree -L 3 -I 'DerivedData|Build' . 2>/dev/null || find . -type f -name "*.swift" -o -name "*.json" | sort

echo ""
echo "✅ Verification complete!"
echo ""
echo "If you see missing files above, make sure you've:"
echo "1. Copied all files from the repository"
echo "2. Added them to your Xcode project"
echo "3. Checked Target Membership for each file"
