# Changelog

All notable changes to the nix-meetily flake will be documented in this file.

## [Unreleased]

### Added
- Initial Nix flake for Meetily app installation
- Support for nix-darwin on macOS
- NixOS module with systemd service integration
- Development shell environment
- Automatic Whisper.cpp compilation from Zackriya-Solutions fork
- Python backend packaging with all dependencies
- Model download utilities (`meetily-download-model`)
- Backend server startup script (`meetily-server`)
- macOS frontend app packaging (from upstream DMG)
- Examples for nix-darwin and NixOS configurations
- Quick install script for easy setup
- Comprehensive documentation

### Features
- **Backend server**: Python FastAPI with Whisper transcription
- **Frontend app**: Tauri-based desktop application (macOS)
- **Model support**: All Whisper model sizes (tiny to large-v3)
- **Language support**: Multi-language transcription
- **Local processing**: Complete privacy with no cloud dependencies
- **Service integration**: Native systemd (NixOS) and LaunchAgent (macOS) support

### Supported Platforms
- macOS (x86_64, aarch64) - Full support with frontend app
- Linux (x86_64, aarch64) - Backend only, web interface access
- NixOS - Full systemd service integration

### Dependencies
- Python 3.11 with comprehensive ML/AI stack
- Custom Whisper.cpp build with server support
- FFmpeg for audio processing
- CMake and build tools for compilation

## [0.1.0] - 2024-MM-DD

Initial release targeting Meetily v0.0.5 compatibility.