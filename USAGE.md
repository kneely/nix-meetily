# 🎤 nix-meetily Usage Guide

This document provides detailed usage instructions for the Meetily Nix flake.

## Table of Contents

- [Quick Start](#quick-start)
- [Installation Methods](#installation-methods)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)

## Quick Start

### 1. Install Nix (if not already installed)

```bash
# Install Nix package manager
curl -L https://nixos.org/nix/install | sh

# Enable flakes (if not enabled)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 2. Quick Installation

```bash
# Run the quick install script
curl -fsSL https://raw.githubusercontent.com/kneely/nix-meetily/main/install.sh | bash

# Or clone and run locally
git clone https://github.com/kneely/nix-meetily
cd nix-meetily
./install.sh
```

### 3. Start Using Meetily

```bash
# Download a Whisper model (required for transcription)
meetily-download-model base

# Start the backend server
meetily-server

# Open web interface at http://localhost:5167
```

## Installation Methods

### Method 1: Direct Installation

Best for: Testing, temporary use, or standalone installation.

```bash
# Install backend directly
nix profile install github:kneely/nix-meetily

# Or install specific packages
nix profile install github:kneely/nix-meetily#meetily-backend
nix profile install github:kneely/nix-meetily#whisper-cpp-meetily
```

### Method 2: nix-darwin Integration (macOS)

Best for: Permanent installation with system configuration management.

Add to your nix-darwin `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-meetily.url = "github:kneely/nix-meetily";
  };

  outputs = { self, nixpkgs, nix-darwin, nix-meetily }:
  let
    configuration = { pkgs, ... }: {
      imports = [ nix-meetily.darwinModules.default ];
      
      services.meetily = {
        enable = true;
        model = "base";
        language = "en";
        autoStart = false;
      };
    };
  in
  {
    darwinConfigurations.your-hostname = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
```

Then rebuild your system:

```bash
darwin-rebuild switch --flake .
```

### Method 3: NixOS Integration

Best for: NixOS systems with systemd service management.

Add to your NixOS configuration:

```nix
{
  imports = [ inputs.nix-meetily.nixosModules.default ];
  
  services.meetily = {
    enable = true;
    user = "meetily";
    dataDir = "/var/lib/meetily";
    model = "base";
    language = "en";
  };
  
  # Optional: Open firewall for remote access
  networking.firewall.allowedTCPPorts = [ 8178 5167 ];
}
```

### Method 4: Development Environment

Best for: Contributing to Meetily or customizing the build.

```bash
# Enter development shell
nix develop github:kneely/nix-meetily

# Or clone and develop locally
git clone https://github.com/kneely/nix-meetily
cd nix-meetily
nix develop

# Build specific packages
nix build .#meetily-backend
nix build .#whisper-cpp-meetily
```

## Configuration

### Model Selection

Choose the appropriate Whisper model for your needs:

| Model | Size | RAM Usage | Speed | Accuracy | Use Case |
|-------|------|-----------|-------|----------|----------|
| `tiny` | 39 MB | ~1 GB | Fastest | Basic | Quick testing, resource-constrained |
| `base` | 142 MB | ~1 GB | Fast | Good | General use (recommended) |
| `small` | 244 MB | ~2 GB | Medium | Better | Better accuracy needed |
| `medium` | 769 MB | ~5 GB | Slow | High | High accuracy requirements |
| `large-v3` | 1550 MB | ~10 GB | Slowest | Best | Maximum accuracy |

Download models:

```bash
# Download recommended model
meetily-download-model base

# Download multiple models
meetily-download-model small
meetily-download-model medium

# List available models
meetily-download-model --help
```

### Language Configuration

Meetily supports multiple languages for transcription:

```bash
# English (default)
meetily-server --language en

# Spanish
meetily-server --language es

# French
meetily-server --language fr

# German
meetily-server --language de

# Auto-detect language
meetily-server --language auto
```

### Service Configuration

#### nix-darwin Configuration Options

```nix
services.meetily = {
  enable = true;                    # Enable the service
  package = /* override */;         # Custom backend package
  frontendPackage = /* override */; # Custom frontend package
  autoStart = false;               # Auto-start on login
  model = "base";                  # Default model
  language = "en";                 # Default language
};
```

#### NixOS Configuration Options

```nix
services.meetily = {
  enable = true;                    # Enable the service
  user = "meetily";                # Service user
  group = "meetily";               # Service group
  dataDir = "/var/lib/meetily";    # Data directory
  whisperPort = 8178;              # Whisper server port
  apiPort = 5167;                  # API server port
  model = "base";                  # Default model
  language = "en";                 # Default language
};
```

## Usage Examples

### Basic Usage

```bash
# Start with default settings
meetily-server

# Start with specific model and language
meetily-server --model medium --language fr

# Download additional models
meetily-download-model large-v3

# Check help
meetily-server --help
```

### Advanced Usage

#### Custom Data Directory

```bash
# Set custom data directory
export MEETILY_DATA_DIR="$HOME/Documents/Meetily"
meetily-server --model base
```

#### Multiple Language Support

```bash
# Download models for different languages
meetily-download-model base.en    # English-optimized
meetily-download-model small      # Multilingual
meetily-download-model medium     # Better multilingual

# Start with auto-detection
meetily-server --model small --language auto
```

#### Integration with Other Tools

```bash
# Use with recording software
# 1. Start Meetily backend
meetily-server --model base &

# 2. Record your meeting audio
# 3. Access transcription via API
curl -X POST "http://localhost:8178/inference" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@meeting-audio.wav"

# 4. View results in web interface
open http://localhost:5167
```

### API Usage

The Meetily backend exposes REST APIs:

```bash
# Whisper transcription API (port 8178)
curl -X POST "http://localhost:8178/inference" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@audio.wav"

# Meetily meeting API (port 5167)
curl -X GET "http://localhost:5167/meetings"

# API documentation
open http://localhost:5167/docs
```

### Web Interface

Access the web interface at http://localhost:5167:

- **Meetings**: View and manage recorded meetings
- **Live Recording**: Start new meeting recordings
- **Transcripts**: Browse and search meeting transcripts
- **Settings**: Configure models, languages, and preferences
- **API Docs**: Interactive API documentation

## Troubleshooting

### Common Issues

#### 1. "Command not found: meetily-server"

```bash
# Check installation
nix profile list | grep meetily

# Reinstall if needed
nix profile install github:kneely/nix-meetily

# Or use direct path
$(nix build github:kneely/nix-meetily --print-out-paths)/bin/meetily-server
```

#### 2. "Model not found" error

```bash
# Download the requested model
meetily-download-model base

# Check available models
ls ~/.local/share/meetily/models/

# Use a different model
meetily-server --model tiny  # Use smallest model
```

#### 3. Port conflicts

```bash
# Check what's using the ports
lsof -i :8178
lsof -i :5167

# Kill conflicting processes
sudo kill -9 $(lsof -t -i:8178)
sudo kill -9 $(lsof -t -i:5167)
```

#### 4. Build failures

```bash
# Clean and rebuild
nix flake update
nix build --rebuild github:kneely/nix-meetily

# Or try development build
git clone https://github.com/kneely/nix-meetily
cd nix-meetily
nix develop
nix build
```

#### 5. macOS permission issues

```bash
# Clear quarantine attributes
xattr -cr /Applications/meetily-frontend.app

# Grant microphone permissions in System Preferences
# System Preferences > Security & Privacy > Privacy > Microphone
```

### Performance Tuning

#### Optimize for Speed

```bash
# Use smaller model
meetily-server --model tiny

# English-only model (faster)
meetily-download-model base.en
meetily-server --model base.en --language en
```

#### Optimize for Accuracy

```bash
# Use larger model
meetily-download-model large-v3
meetily-server --model large-v3

# Enable all features
meetily-server --model large-v3 --language auto
```

#### Resource Management

```bash
# Monitor resource usage
htop
iotop

# Check GPU usage (if applicable)
nvidia-smi  # NVIDIA
rocm-smi    # AMD
```

### Getting Help

1. **Documentation**: Check the main [README](README.md)
2. **Examples**: Review the [examples](examples/) directory
3. **Issues**: Report bugs at https://github.com/kneely/nix-meetily/issues
4. **Upstream**: For Meetily app issues, see https://github.com/Zackriya-Solutions/meeting-minutes
5. **Community**: Join discussions in the Meetily Discord or Reddit community

### Debug Mode

```bash
# Enable verbose logging
RUST_LOG=info meetily-server --model base

# Check service logs (NixOS)
journalctl -fu meetily-backend

# Check service logs (nix-darwin)
tail -f /tmp/meetily-backend.log
```