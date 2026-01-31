{ config, pkgs, ... }:
{
    imports = [
        ./hardware-configuration.nix
        ../../users/dave.nix
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos";
    
    # Fingerprint reader support / firmware updates
    services.fwupd.enable = true;
    services.fprintd.enable = true;

    # Fingerprint auth (do NOT set `login` when using GDM; it conflicts)
    security.pam.services.sudo.fprintAuth = true;

    # GNOME / GDM
    security.pam.services.gdm.fprintAuth = true;
    security.pam.services.gdm-password.fprintAuth = true;
    security.pam.services.gdm.enableGnomeKeyring = true;
    security.pam.services.gdm-password.enableGnomeKeyring = true;

    system.stateVersion = "25.11";
}
