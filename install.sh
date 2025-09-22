#!/usr/bin/env bash
# Quick install script for Meetily using nix-meetily flake

set -euo pipefail

echo "🎤 Meetily Quick Install Script"
echo "==============================="
echo ""

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo "❌ Nix is not installed. Please install Nix first:"
    echo "   curl -L https://nixos.org/nix/install | sh"
    exit 1
fi

# Check if flakes are enabled
if ! nix --version | grep -q "flake"; then
    echo "⚠️  Nix flakes don't seem to be enabled."
    echo "   You may need to enable experimental features:"
    echo "   echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf"
    echo ""
    echo "   Continuing anyway..."
fi

# Detect platform
PLATFORM=$(uname)
echo "🖥️  Detected platform: $PLATFORM"
echo ""

case $PLATFORM in
    "Darwin")
        echo "🍎 macOS detected - nix-darwin integration available"
        echo ""
        echo "Installation options:"
        echo "1. Direct installation (recommended for testing)"
        echo "2. nix-darwin integration (recommended for permanent setup)"
        echo ""
        read -p "Choose option (1 or 2): " choice
        
        case $choice in
            1)
                echo "Installing Meetily backend directly..."
                nix profile install github:kneely/nix-meetily
                echo ""
                echo "✅ Installation complete!"
                echo ""
                echo "Next steps:"
                echo "1. Download a Whisper model: meetily-download-model base"
                echo "2. Start the backend: meetily-server"
                echo "3. Open http://localhost:5167 in your browser"
                ;;
            2)
                echo "For nix-darwin integration, add this to your flake.nix:"
                echo ""
                cat << 'EOF'
{
  inputs = {
    nix-meetily.url = "github:kneely/nix-meetily";
    # ... your other inputs
  };
  
  outputs = { self, nix-meetily, darwin, ... }: {
    darwinConfigurations.your-system = darwin.lib.darwinSystem {
      modules = [
        nix-meetily.darwinModules.default
        {
          services.meetily = {
            enable = true;
            model = "base";
            language = "en";
          };
        }
      ];
    };
  };
}
EOF
                echo ""
                echo "Then rebuild your system: darwin-rebuild switch --flake ."
                ;;
        esac
        ;;
    "Linux")
        echo "🐧 Linux detected"
        echo ""
        if [[ -f /etc/nixos/configuration.nix ]]; then
            echo "NixOS detected - systemd service integration available"
            echo "See examples/nixos-config.nix for configuration options"
        else
            echo "Installing on non-NixOS Linux..."
        fi
        
        echo "Installing Meetily backend..."
        nix profile install github:kneely/nix-meetily
        echo ""
        echo "✅ Installation complete!"
        echo ""
        echo "Next steps:"
        echo "1. Download a Whisper model: meetily-download-model base"
        echo "2. Start the backend: meetily-server"
        echo "3. Open http://localhost:5167 in your browser"
        ;;
    *)
        echo "❌ Unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

echo ""
echo "📚 For more information:"
echo "   - Documentation: https://github.com/kneely/nix-meetily"
echo "   - Upstream project: https://github.com/Zackriya-Solutions/meeting-minutes"
echo ""
echo "🎉 Enjoy using Meetily!"