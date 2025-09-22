# Example NixOS configuration with Meetily
# Add this to your NixOS configuration.nix

{ config, pkgs, ... }:

{
  imports = [
    # Import the Meetily NixOS module
    # You'll need to add this to your flake inputs first
    # inputs.nix-meetily.nixosModules.default
  ];

  # Enable Meetily service
  services.meetily = {
    enable = true;
    user = "meetily";
    group = "meetily";
    dataDir = "/var/lib/meetily";
    whisperPort = 8178;
    apiPort = 5167;
    model = "base";       # Choose: tiny, base, small, medium, large-v3
    language = "en";      # Language code for transcription
  };

  # Open firewall ports (optional, for remote access)
  networking.firewall.allowedTCPPorts = [ 8178 5167 ];

  # Optional: Install Meetily backend globally
  environment.systemPackages = [
    # This will be available from the flake
    # inputs.nix-meetily.packages.${pkgs.system}.meetily-backend
  ];

  # Optional: Add shell aliases for convenience
  environment.shellAliases = {
    meetily-start = "systemctl start meetily-backend";
    meetily-stop = "systemctl stop meetily-backend";
    meetily-status = "systemctl status meetily-backend";
    meetily-logs = "journalctl -fu meetily-backend";
  };
}