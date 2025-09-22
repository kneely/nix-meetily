# GitHub Copilot Instructions for nix-meetily

ALWAYS follow these instructions first and only fallback to additional search and context gathering if the information below is incomplete or found to be in error.

## Overview

nix-meetily is a Nix flake that packages Meetily, an AI-powered meeting assistant. The repository contains three main packages (meetily-backend, whisper-cpp-meetily, meetily-frontend), NixOS/nix-darwin system modules, and comprehensive documentation.

## Prerequisites and Setup

### Required Software Installation
- **CRITICAL**: Install Nix package manager first:
  ```bash
  curl -L https://nixos.org/nix/install | sh
  ```
- Enable Nix flakes:
  ```bash
  mkdir -p ~/.config/nix
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
  ```

### Repository Setup
- Clone repository:
  ```bash
  git clone https://github.com/kneely/nix-meetily
  cd nix-meetily
  ```

## Build Instructions

### CRITICAL Build Timing and Timeout Information

**NEVER CANCEL builds or long-running commands.** Nix builds can take significant time due to complex dependencies.

### Build Commands and Timeouts

1. **Enter development environment**:
   ```bash
   nix develop
   ```
   - **Timeout**: Set to 20+ minutes for first run
   - **Time expectation**: 5-15 minutes (downloads dependencies)

2. **Build all packages**:
   ```bash
   nix build
   ```
   - **NEVER CANCEL**: Build takes 30-45 minutes on first run
   - **Timeout**: Set to 60+ minutes minimum
   - **Components**: Compiles whisper.cpp C++ code + Python ML dependencies

3. **Build specific packages**:
   ```bash
   nix build .#meetily-backend          # 15-30 minutes
   nix build .#whisper-cpp-meetily      # 20-40 minutes (C++ compilation)
   nix build .#meetily-frontend         # 5-10 minutes (macOS only)
   ```
   - **NEVER CANCEL**: C++ builds are especially time-consuming
   - **Timeout**: Set individual timeouts to 45+ minutes

4. **Validate flake syntax**:
   ```bash
   nix flake check --no-build
   ```
   - **Timeout**: 5 minutes
   - **Time expectation**: 1-2 minutes

## Installation and Testing

### Install for Testing
```bash
nix profile install .
```
- **Timeout**: 10+ minutes
- **Time expectation**: 5-8 minutes

### CRITICAL Validation Scenarios

**ALWAYS run these validation steps after making changes:**

1. **Download and test with tiny model** (fastest for testing):
   ```bash
   meetily-download-model tiny
   ```
   - **Time expectation**: 1-2 minutes (downloads ~39MB)
   - **Storage location**: `~/.local/share/meetily/models/`

2. **Start backend server**:
   ```bash
   meetily-server --model tiny
   ```
   - **Expected behavior**: Two services start (Whisper on port 8178, FastAPI on port 5167)
   - **Startup time**: 10-15 seconds
   - **Expected output**: Green success messages with port information

3. **Test API endpoints** (in separate terminal):
   ```bash
   # Test Whisper health endpoint
   curl http://localhost:8178/health
   
   # Test FastAPI documentation
   curl http://localhost:5167/docs
   
   # Test meetings API
   curl http://localhost:5167/meetings
   ```
   - **Expected result**: All should return HTTP 200 responses
   - **Whisper health**: Should return status information
   - **FastAPI docs**: Should return HTML documentation page

4. **Manual UI validation**:
   - Open browser to `http://localhost:5167`
   - **REQUIRED**: Verify web interface loads completely
   - **REQUIRED**: Check that these sections are present:
     - Meetings dashboard
     - Live recording interface  
     - API documentation link
   - **Test file upload** (if audio file available):
     ```bash
     # Test transcription API with audio file
     curl -X POST "http://localhost:8178/inference" \
       -H "Content-Type: multipart/form-data" \
       -F "file=@test-audio.wav"
     ```

5. **Verify shutdown behavior**:
   - Press `Ctrl+C` in meetily-server terminal
   - **Expected output**: Clean shutdown messages for both services
   - **Verify**: Ports 8178 and 5167 are released
   ```bash
   # Confirm ports are free
   lsof -i :8178 || echo "Port 8178 free"
   lsof -i :5167 || echo "Port 5167 free"
   ```

## System Requirements and Cross-Platform Notes

### Minimum Requirements
- **RAM**: 8GB minimum, 16GB+ recommended for larger models
- **Storage**: 4GB+ free disk space
- **Platform**: macOS 10.15+ or Linux (any recent version)

### Architecture Support
- **x86_64**: Full support on macOS and Linux
- **aarch64** (Apple Silicon): Full support with Metal acceleration

### Platform-Specific Features
- **macOS**: Includes frontend application, Metal acceleration for Whisper
- **Linux**: Backend only, optional CUDA support
- **NixOS**: Native systemd service integration
- **nix-darwin**: LaunchAgent integration for macOS

### Cross-Platform Development
```bash
# Build for different architectures
nix build .#meetily-backend --system x86_64-linux
nix build .#meetily-backend --system aarch64-darwin
```

**Frontend Availability**: 
- `meetily-frontend` package only available on macOS
- Other platforms use web interface at http://localhost:5167

## Model Information

Available Whisper models for testing and production:

| Model | Size | RAM Usage | Speed | Accuracy | Best For |
|-------|------|-----------|-------|----------|----------|
| `tiny` | 39MB | ~1GB | Fastest | Basic | Development/testing, low resources |
| `base` | 142MB | ~1GB | Fast | Good | General use (recommended) |
| `small` | 244MB | ~2GB | Medium | Better | Better accuracy needs |
| `medium` | 769MB | ~5GB | Slow | High | High accuracy requirements |
| `large-v3` | 1550MB | ~10GB | Slowest | Best | Maximum accuracy |

**For development**: Always use `tiny` model to minimize download time and resource usage.

**Model storage location**: `~/.local/share/meetily/models/`

## Port Configuration

**Default ports** (document any conflicts):
- **8178**: Whisper transcription server
- **5167**: Meetily FastAPI backend

Check for port conflicts:
```bash
lsof -i :8178
lsof -i :5167
```

## Common Development Tasks

### Show Available Flake Outputs
```bash
nix flake show
```
- **Shows**: Available packages, apps, and development shells
- **Use for**: Understanding what can be built

### Update Dependencies
```bash
nix flake update
```
- **Timeout**: 10 minutes
- **Time expectation**: 2-5 minutes

### Debug Build Issues
```bash
nix build --verbose .#meetily-backend
```
- **Use for**: Troubleshooting build failures
- **Timeout**: 60+ minutes

### Test Individual Components
```bash
# Test Python environment
nix shell .#meetily-backend -c python -c "import fastapi; print('OK')"

# Test whisper binary
nix shell .#whisper-cpp-meetily -c whisper-server --help

# Test development shell
nix develop

# Run specific apps
nix run .#meetily-server -- --help
nix run .#meetily-download-model -- tiny
```

### Development Shell Usage
```bash
nix develop
```
- **Provides**: Python environment, build tools, development dependencies
- **Available tools**: cmake, pkg-config, ffmpeg, curl, git
- **Use for**: Interactive development and debugging

## System Integration Testing

### nix-darwin Module (macOS)
Test configuration builds:
```bash
darwin-rebuild build --flake .#test-darwin
```
- **Note**: Creates test configuration, doesn't activate

### NixOS Module (Linux)
Test VM creation:
```bash
nixos-rebuild build-vm --flake .#test-nixos
./result/bin/run-*-vm
```
- **Resource requirement**: 4GB+ RAM for VM

## Repository Structure

Key directories and files:
```
nix-meetily/
├── flake.nix              # Main package definitions
├── flake.lock             # Locked dependency versions  
├── README.md              # Main documentation
├── USAGE.md               # Detailed usage guide
├── DEVELOPMENT.md         # Development workflows
├── install.sh             # Quick install script
├── validate.sh            # Repository validation script
└── examples/              # Configuration examples
    ├── nix-darwin-config.nix
    └── nixos-config.nix
```

## Pre-commit Validation

**ALWAYS run before committing changes:**

1. **Validate repository structure**:
   ```bash
   ./validate.sh
   ```
   - **Timeout**: 5 minutes
   - **Expected result**: All checks pass

2. **Test package builds**:
   ```bash
   nix build .#meetily-backend
   ```
   - **NEVER CANCEL**: 30-45 minutes
   - **Required**: Must complete successfully

3. **Test installation flow**:
   ```bash
   nix profile install .
   meetily-download-model tiny
   meetily-server --model tiny &
   curl http://localhost:8178/health
   curl http://localhost:5167/docs
   ```

## Troubleshooting

### Hash Mismatches
- Set hash to empty string, run build to get correct hash
- Use `nix-prefetch-url` or `nix-prefetch-github` for sources

### Platform Issues
- **macOS**: Ensure Apple SDK frameworks available
- **Linux**: Check CUDA/CPU variants if GPU acceleration fails

### Python Import Errors
- Verify PYTHONPATH includes backend directory
- Use provided `meetily-server` script, not direct Python execution

### Common Runtime Issues

1. **"Model not found" error**:
   ```bash
   # Download required model first
   meetily-download-model base
   ```

2. **Port conflicts**:
   ```bash
   # Check what's using the ports
   lsof -i :8178
   lsof -i :5167
   
   # Kill conflicting processes if needed
   sudo kill -9 $(lsof -t -i:8178)
   sudo kill -9 $(lsof -t -i:5167)
   ```

3. **macOS permission issues**:
   ```bash
   # Clear quarantine attributes
   xattr -cr /Applications/meetily-frontend.app
   ```

4. **Build failures**:
   ```bash
   # Clean and rebuild
   nix flake update
   nix build --rebuild .#meetily-backend
   ```

5. **Service startup failures**:
   - Check if all models are downloaded
   - Verify ports are available
   - Check system resources (RAM/disk space)
   - Review logs for specific error messages

## Performance Notes

### Build Performance
- **First build**: 30-45 minutes (downloads + compilation)
- **Incremental builds**: 5-15 minutes 
- **Development shell**: 5-15 minutes first time

### Runtime Performance
- **Server startup**: 10-15 seconds
- **Model loading**: Varies by model size (tiny: 1-2s, large: 10-30s)

## CRITICAL Reminders

- **NEVER CANCEL** long-running Nix builds
- **ALWAYS** test with `tiny` model during development
- **ALWAYS** validate API endpoints after changes
- **ALWAYS** run `./validate.sh` before committing
- **TIMEOUT SETTINGS**: Use 60+ minutes for builds, 30+ minutes for tests
- **VALIDATION REQUIREMENT**: Test complete user scenarios, not just startup/shutdown

When in doubt about timing, err on the side of longer timeouts. Nix builds that appear to hang are often still working.