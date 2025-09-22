#!/usr/bin/env bash
# Basic validation script for nix-meetily flake

set -euo pipefail

echo "🧪 Testing nix-meetily flake..."
echo "==============================="

# Check if we're in the right directory
if [[ ! -f "flake.nix" ]]; then
    echo "❌ Error: flake.nix not found. Run this script from the repository root."
    exit 1
fi

echo "📁 Repository structure check..."
required_files=(
    "flake.nix"
    "flake.lock"
    "README.md"
    "USAGE.md"
    "DEVELOPMENT.md"
    "CHANGELOG.md"
    "install.sh"
    "examples/nix-darwin-config.nix"
    "examples/nixos-config.nix"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (missing)"
        missing_files+=("$file")
    fi
done

if [[ ${#missing_files[@]} -gt 0 ]]; then
    echo "❌ Missing required files: ${missing_files[*]}"
    exit 1
fi

echo ""
echo "🔍 Flake structure validation..."

# Check if nix is available
if ! command -v nix &> /dev/null; then
    echo "⚠️  Nix not found, skipping build tests"
    echo "   Install Nix to run full validation: https://nixos.org/download.html"
else
    echo "📦 Nix found, running flake checks..."
    
    # Check flake syntax
    echo "  🔍 Checking flake syntax..."
    if nix flake check --no-build 2>/dev/null; then
        echo "  ✅ Flake syntax is valid"
    else
        echo "  ❌ Flake syntax errors found"
        echo "  Run 'nix flake check' for details"
        exit 1
    fi
    
    # Show available outputs
    echo "  📋 Available outputs:"
    nix flake show 2>/dev/null | sed 's/^/    /' || echo "    (Unable to show outputs)"
    
    echo ""
    echo "🏗️  Build tests (these may take time and require network)..."
    echo "   To run build tests manually:"
    echo "   - nix build .#meetily-backend"
    echo "   - nix build .#whisper-cpp-meetily"
    echo "   - nix develop"
fi

echo ""
echo "📚 Documentation validation..."

# Check README has required sections
required_sections=(
    "# nix-meetily"
    "## Quick Start"
    "## Usage"
    "## Installation"
)

echo "  📖 Checking README.md sections..."
for section in "${required_sections[@]}"; do
    if grep -q "^$section" README.md; then
        echo "    ✅ $section"
    else
        echo "    ❌ $section (missing)"
    fi
done

# Check example configurations
echo "  📝 Checking example configurations..."
if [[ -f "examples/nix-darwin-config.nix" ]]; then
    if grep -q "services.meetily" examples/nix-darwin-config.nix; then
        echo "    ✅ nix-darwin example has Meetily service config"
    else
        echo "    ❌ nix-darwin example missing Meetily service config"
    fi
fi

if [[ -f "examples/nixos-config.nix" ]]; then
    if grep -q "services.meetily" examples/nixos-config.nix; then
        echo "    ✅ NixOS example has Meetily service config"
    else
        echo "    ❌ NixOS example missing Meetily service config"
    fi
fi

echo ""
echo "🎯 Integration checks..."

# Check if install script is executable
if [[ -x "install.sh" ]]; then
    echo "  ✅ install.sh is executable"
else
    echo "  ❌ install.sh is not executable"
    echo "    Run: chmod +x install.sh"
fi

# Check flake.lock exists and is valid JSON
if [[ -f "flake.lock" ]]; then
    if python3 -m json.tool flake.lock > /dev/null 2>&1; then
        echo "  ✅ flake.lock is valid JSON"
    else
        echo "  ❌ flake.lock is invalid JSON"
    fi
fi

echo ""
echo "🎉 Validation complete!"
echo ""
echo "💡 Next steps:"
echo "   1. Test installation: ./install.sh"
echo "   2. Test development: nix develop"
echo "   3. Test builds: nix build"
echo "   4. Review documentation and examples"
echo ""
echo "🔗 Useful commands:"
echo "   - nix flake show                    # Show available outputs"
echo "   - nix develop                       # Enter development shell"
echo "   - nix run .#meetily-server -- --help  # Run meetily server"
echo "   - nix build .#meetily-backend       # Build backend package"