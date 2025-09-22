# nix-meetily

A Nix flake for installing [Meetily](https://github.com/Zackriya-Solutions/meeting-minutes) - a privacy-first AI meeting assistant that runs entirely on your local infrastructure.

## About Meetily

Meetily is an open-source meeting transcription and analysis application that provides:

- **Privacy-First**: All processing happens locally on your device
- **Real-time transcription** using locally-running Whisper
- **AI-powered meeting summaries** with support for multiple LLM providers
- **Cross-platform support** for macOS and Windows
- **Enterprise-ready** with complete data sovereignty

This flake packages both the backend server (Python FastAPI + Whisper.cpp) and frontend application for easy installation with Nix, particularly for nix-darwin on macOS.

## Installation

### Prerequisites

Before installing Meetily with Nix, ensure you have:

- **Nix package manager** with flakes enabled
- **macOS 10.15+** (for frontend app) or **Linux** (backend only)
- **8GB+ RAM** (16GB+ recommended for larger models)
- **4GB+ free disk space**

### Enable Nix Flakes

If you haven't already enabled flakes:

```bash
# Create nix config directory
mkdir -p ~/.config/nix

# Enable experimental features
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Quick Installation

The fastest way to get started:

```bash
# Run the installation script
curl -fsSL https://raw.githubusercontent.com/kneely/nix-meetily/main/install.sh | bash
```

### Manual Installation

For more control over the installation process:

```bash
# Install directly with nix profile
nix profile install github:kneely/nix-meetily

# Or install specific components
nix profile install github:kneely/nix-meetily#meetily-backend
nix profile install github:kneely/nix-meetily#whisper-cpp-meetily
```

## Quick Start

### Installation with nix-darwin

Add this flake to your nix-darwin configuration:

```nix
{
  inputs = {
    nix-meetily.url = "github:kneely/nix-meetily";
    # ... your other inputs
  };

  outputs = { self, nix-meetily, darwin, ... }: {
    darwinConfigurations.your-system = darwin.lib.darwinSystem {
      # ... your configuration
      modules = [
        nix-meetily.darwinModules.default
        {
          services.meetily = {
            enable = true;
            model = "base";  # or "small", "medium", "large-v3"
            language = "en";
            autoStart = false;  # Set to true to auto-start backend
          };
        }
      ];
    };
  };
}
```

### Direct Installation

```bash
# Install the backend server
nix profile install github:kneely/nix-meetily

# Download a Whisper model (required for transcription)
meetily-download-model base

# Start the backend server
meetily-server --model base --language en
```

### Development Environment

```bash
# Enter development shell
nix develop github:kneely/nix-meetily

# Or run directly
nix run github:kneely/nix-meetily
```

## Usage

### Backend Server

The backend server provides two services:

1. **Whisper Server** (port 8178) - Audio transcription
2. **Meetily API** (port 5167) - Meeting management and AI analysis

```bash
# Start with default settings
meetily-server

# Start with specific model and language
meetily-server --model medium --language fr

# Help
meetily-server --help
```

### Model Management

Download Whisper models for transcription:

```bash
# Available models: tiny, base, small, medium, large-v3
meetily-download-model small

# Models are stored in ~/.local/share/meetily/models/
```

### Model Selection Guide

| Model | Size | Speed | Accuracy | Best For |
|-------|------|-------|----------|----------|
| tiny | ~39 MB | Fastest | Basic | Testing, low resources |
| base | ~142 MB | Fast | Good | General use (recommended) |
| small | ~244 MB | Medium | Better | Better accuracy needs |
| medium | ~769 MB | Slow | High | High accuracy requirements |
| large-v3 | ~1550 MB | Slowest | Best | Maximum accuracy |

### Frontend Application

The frontend is a Tauri-based desktop application. On macOS, it will be available in `/Applications/meetily-frontend.app` when installed via nix-darwin.

For other platforms, you can access the web interface at http://localhost:5167 when the backend is running.

## Configuration

### nix-darwin Configuration Options

```nix
services.meetily = {
  enable = true;                    # Enable Meetily service
  package = /* custom package */;   # Override backend package
  frontendPackage = /* custom */;   # Override frontend package (macOS only)
  autoStart = false;               # Auto-start backend on login
  model = "base";                  # Default Whisper model
  language = "en";                 # Default transcription language
};
```

### NixOS Configuration

For NixOS systems, you can use the NixOS module:

```nix
{
  imports = [ nix-meetily.nixosModules.default ];
  
  services.meetily = {
    enable = true;
    user = "meetily";
    group = "meetily";
    dataDir = "/var/lib/meetily";
    whisperPort = 8178;
    apiPort = 5167;
    model = "base";
    language = "en";
  };
}
```

## Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/kneely/nix-meetily
cd nix-meetily

# Enter development shell
nix develop

# Build packages
nix build .#meetily-backend
nix build .#whisper-cpp-meetily
nix build .#meetily-frontend  # macOS only
```

### Available Packages

- `meetily-backend` - Python FastAPI server with all dependencies
- `whisper-cpp-meetily` - Custom Whisper.cpp build with server support
- `meetily-frontend` - Tauri frontend application (macOS only)

### Updating

To update the flake inputs:

```bash
nix flake update
```

## Troubleshooting

### Common Issues

1. **"Model not found" error**
   ```bash
   # Download a model first
   meetily-download-model base
   ```

2. **Port conflicts**
   ```bash
   # Check if ports 8178/5167 are in use
   lsof -i :8178
   lsof -i :5167
   ```

3. **Permission errors on macOS**
   ```bash
   # Clear quarantine attributes
   xattr -cr /Applications/meetily-frontend.app
   ```

4. **Python import errors**
   - Ensure you're using the provided `meetily-server` script
   - Check that PYTHONPATH includes the backend directory

### Logs and Debugging

Backend logs are written to stdout when running `meetily-server`. For the nix-darwin LaunchAgent:

```bash
# View logs
tail -f /tmp/meetily-backend.log
tail -f /tmp/meetily-backend.error.log
```

## Requirements

### System Requirements
- **macOS**: 10.15+ (Monterey+ recommended for frontend)
- **NixOS/Linux**: Any recent version
- **RAM**: 8GB minimum, 16GB+ recommended
- **Storage**: 4GB+ free space

### Architecture Support
- **x86_64**: Full support
- **aarch64** (Apple Silicon): Full support with Metal acceleration

## Contributing

This flake is based on the official [Meetily project](https://github.com/Zackriya-Solutions/meeting-minutes). Please report issues with:

- **Flake packaging**: This repository
- **Meetily application**: [Upstream repository](https://github.com/Zackriya-Solutions/meeting-minutes)

## License

This flake is released under the MIT License. Meetily itself is also MIT licensed.

## Acknowledgments

- [Meetily](https://github.com/Zackriya-Solutions/meeting-minutes) by Zackriya Solutions
- [Whisper.cpp](https://github.com/ggerganov/whisper.cpp) for efficient local transcription
- [Homebrew Meetily](https://github.com/Zackriya-Solutions/homebrew-meetily) for packaging inspiration