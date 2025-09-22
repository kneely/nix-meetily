# Development Guide for nix-meetily

This guide covers development, testing, and contribution workflows for the nix-meetily flake.

## Development Setup

### Prerequisites

- Nix package manager with flakes enabled
- Git for version control
- Basic understanding of Nix flakes and Nix expressions

### Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/kneely/nix-meetily
   cd nix-meetily
   ```

2. **Enter development environment**:
   ```bash
   nix develop
   ```

3. **Build and test packages**:
   ```bash
   # Build all packages
   nix build

   # Build specific packages
   nix build .#meetily-backend
   nix build .#whisper-cpp-meetily
   nix build .#meetily-frontend  # macOS only
   ```

## Project Structure

```
nix-meetily/
├── flake.nix              # Main flake definition
├── flake.lock             # Locked dependency versions
├── README.md              # Main documentation
├── USAGE.md               # Detailed usage guide
├── CHANGELOG.md           # Version history
├── install.sh             # Quick install script
├── examples/              # Configuration examples
│   ├── nix-darwin-config.nix
│   └── nixos-config.nix
└── .gitignore             # Git ignore rules
```

## Package Architecture

### meetily-backend

The backend package includes:

- **Python Environment**: Pre-configured with all ML/AI dependencies
- **Whisper.cpp Integration**: Custom build with server support
- **CLI Tools**: `meetily-server` and `meetily-download-model`
- **Service Scripts**: Startup and management scripts

Key components:
```nix
pythonEnv = pkgs.python311.withPackages (ps: with ps; [
  fastapi uvicorn websockets python-multipart
  requests aiofiles python-dotenv sqlite-fts4
  anthropic groq openai chromadb sentence-transformers
  numpy scipy scikit-learn pandas pydantic httpx
  asyncio-mqtt psutil
]);
```

### whisper-cpp-meetily

Custom Whisper.cpp build with:
- Server API support (`-DWHISPER_BUILD_SERVER=ON`)
- Platform optimizations (Metal on macOS, CUDA on Linux)
- Static linking for portability

### meetily-frontend

macOS frontend application:
- Fetches from upstream DMG releases
- Provides app bundle structure
- Includes web interface fallback

## Testing

### Local Testing

1. **Build packages**:
   ```bash
   nix build .#meetily-backend
   ```

2. **Test installation**:
   ```bash
   nix profile install .
   ```

3. **Test services**:
   ```bash
   # Download a model
   meetily-download-model tiny

   # Start server
   meetily-server --model tiny

   # Test APIs
   curl http://localhost:8178/health
   curl http://localhost:5167/docs
   ```

### Module Testing

#### nix-darwin Module

Create a test configuration:

```nix
# test-darwin.nix
{ inputs, ... }: {
  imports = [ inputs.nix-meetily.darwinModules.default ];
  
  services.meetily = {
    enable = true;
    model = "tiny";  # Use small model for testing
    language = "en";
    autoStart = false;
  };
}
```

Test with:
```bash
darwin-rebuild build --flake .#test-darwin
```

#### NixOS Module

Create a test VM:

```nix
# test-nixos.nix
{ inputs, modulesPath, ... }: {
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
    inputs.nix-meetily.nixosModules.default
  ];
  
  services.meetily = {
    enable = true;
    model = "tiny";
    language = "en";
  };
  
  virtualisation.memorySize = 4096;
}
```

Test with:
```bash
nixos-rebuild build-vm --flake .#test-nixos
./result/bin/run-*-vm
```

## Common Development Tasks

### Updating Dependencies

1. **Update flake inputs**:
   ```bash
   nix flake update
   ```

2. **Update Python dependencies**:
   Edit the `pythonEnv` section in `flake.nix`:
   ```nix
   pythonEnv = pkgs.python311.withPackages (ps: with ps; [
     # Add new packages here
     new-package
   ]);
   ```

3. **Update Meetily version**:
   Update version numbers and hashes throughout `flake.nix`.

### Adding New Features

#### Adding a New Package

1. Define the package in the `packages` output:
   ```nix
   packages = {
     default = meetily-backend;
     meetily-backend = meetily-backend;
     new-package = pkgs.stdenv.mkDerivation {
       # Package definition
     };
   };
   ```

2. Add to appropriate module if needed.

#### Adding Configuration Options

1. **For nix-darwin module**:
   ```nix
   options.services.meetily = {
     newOption = mkOption {
       type = types.str;
       default = "default-value";
       description = "Description of new option";
     };
   };
   ```

2. **For NixOS module**:
   ```nix
   options.services.meetily = {
     newOption = mkOption {
       type = types.str;
       default = "default-value";
       description = "Description of new option";
     };
   };
   ```

### Debugging

#### Build Issues

1. **Verbose builds**:
   ```bash
   nix build --verbose .#meetily-backend
   ```

2. **Debug specific phases**:
   ```bash
   nix develop .#meetily-backend
   cd $TMPDIR
   unpackPhase
   configurePhase
   buildPhase
   ```

3. **Inspect build environment**:
   ```bash
   nix develop .#meetily-backend
   env | grep -E "(PATH|PYTHONPATH|CMAKE)"
   ```

#### Runtime Issues

1. **Test individual components**:
   ```bash
   # Test Python environment
   nix shell .#meetily-backend -c python -c "import fastapi; print('OK')"

   # Test whisper binary
   nix shell .#whisper-cpp-meetily -c whisper-server --help
   ```

2. **Check service logs**:
   ```bash
   # NixOS
   journalctl -fu meetily-backend

   # nix-darwin
   tail -f /tmp/meetily-backend.log
   ```

## Contributing

### Code Style

- Follow Nix best practices and conventions
- Use meaningful variable names
- Add comments for complex logic
- Keep package definitions modular

### Documentation

- Update README.md for user-facing changes
- Update USAGE.md for new features
- Add inline comments for complex Nix expressions
- Include examples for new configuration options

### Pull Request Process

1. **Fork and clone**:
   ```bash
   git clone https://github.com/your-username/nix-meetily
   cd nix-meetily
   ```

2. **Create feature branch**:
   ```bash
   git checkout -b feature/new-feature
   ```

3. **Make changes and test**:
   ```bash
   # Make your changes
   nix build
   nix develop
   # Test thoroughly
   ```

4. **Commit and push**:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   git push origin feature/new-feature
   ```

5. **Create pull request** with:
   - Clear description of changes
   - Testing performed
   - Documentation updates

### Release Process

1. **Update version numbers** in:
   - `flake.nix` (package versions)
   - `CHANGELOG.md` (release notes)

2. **Test on multiple platforms**:
   - macOS (Intel and Apple Silicon)
   - Linux (NixOS and non-NixOS)

3. **Create release tag**:
   ```bash
   git tag -a v0.1.0 -m "Release v0.1.0"
   git push origin v0.1.0
   ```

4. **Update documentation** with new version references.

## Advanced Topics

### Cross-Platform Builds

Build for different platforms:

```bash
# Build for x86_64-linux from macOS
nix build .#meetily-backend --system x86_64-linux

# Build for aarch64-darwin from Linux
nix build .#meetily-backend --system aarch64-darwin
```

### Custom Overlays

Create custom package variants:

```nix
# overlay.nix
final: prev: {
  meetily-backend-dev = prev.meetily-backend.overrideAttrs (oldAttrs: {
    # Custom modifications for development
  });
}
```

### Hydra CI Integration

For automated testing across platforms:

```nix
# hydra-jobs.nix
{ inputs }:
let
  systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
in
builtins.listToAttrs (map (system: {
  name = system;
  value = inputs.self.packages.${system};
}) systems)
```

## Troubleshooting Development Issues

### Common Build Failures

1. **Python dependency conflicts**:
   - Check for version conflicts in `pythonEnv`
   - Use `python311.withPackages` consistently
   - Verify all dependencies are available in nixpkgs

2. **CMake build failures**:
   - Ensure all build dependencies are listed
   - Check platform-specific requirements
   - Verify CMake flags are correct

3. **Hash mismatches**:
   - Update hashes when source changes
   - Use `nix-prefetch-url` or `nix-prefetch-github`
   - Set hash to empty string to get correct value

### Performance Issues

1. **Slow builds**:
   - Use binary caches when available
   - Enable ccache for C++ builds
   - Parallelize builds with `-j` flag

2. **Large closures**:
   - Minimize dependencies
   - Use `separateDebugInfo`
   - Remove unnecessary build tools from runtime

### Platform-Specific Issues

1. **macOS Metal support**:
   - Ensure Apple SDK frameworks are included
   - Test on both Intel and Apple Silicon
   - Verify code signing requirements

2. **Linux CUDA support**:
   - Handle CUDA toolkit dependencies
   - Provide both CPU and GPU variants
   - Test across different CUDA versions

## Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [NixOS Options Search](https://search.nixos.org/options)
- [Nix Package Search](https://search.nixos.org/packages)
- [Meetily Documentation](https://github.com/Zackriya-Solutions/meeting-minutes)