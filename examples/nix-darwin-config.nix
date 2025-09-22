# Example nix-darwin configuration with Meetily
# Add this to your nix-darwin flake.nix configuration

{
  description = "My macOS system configuration with Meetily";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-meetily.url = "github:kneely/nix-meetily";
  };

  outputs = { self, nixpkgs, nix-darwin, nix-meetily }:
  let
    configuration = { pkgs, ... }: {
      # Import the Meetily nix-darwin module
      imports = [ nix-meetily.darwinModules.default ];

      # Enable Meetily service
      services.meetily = {
        enable = true;
        model = "base";      # Choose: tiny, base, small, medium, large-v3
        language = "en";     # Language code for transcription
        autoStart = false;   # Set to true to auto-start backend on login
      };

      # Add Meetily to system packages (optional, already included by the service)
      # environment.systemPackages = [ nix-meetily.packages.${pkgs.system}.meetily-backend ];

      # Enable experimental features for flakes
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      # Your other configuration options...
      programs.zsh.enable = true;
      services.nix-daemon.enable = true;
      
      # Optional: Add shell aliases for convenience
      environment.shellAliases = {
        meetily-start = "meetily-server --model base --language en";
        meetily-download = "meetily-download-model";
      };
    };
  in
  {
    darwinConfigurations = {
      # Replace "hostname" with your system hostname
      hostname = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
  };
}