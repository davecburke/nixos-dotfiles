{ config, pkgs, ... }:
{
  # If you prefer to keep hardware import here:
  imports = [
    ../hardware-configuration.nix
    ../../users/dave.nix
  ];

  # Bootloader (host-level)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";

  # # User(s) on this machine
  # users.users.dave = {
  #   isNormalUser = true;
  #   description = "David Burke";
  #   extraGroups = [ "networkmanager" "wheel" ];
  #   packages = with pkgs; [
  #     # keep empty if you want
  #   ];
  # };

  # Do not move this between machines/configs
  system.stateVersion = "25.11";
}
