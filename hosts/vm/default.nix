{ config, pkgs, ... }:
{
    imports = [
        ./hardware-configuration.nix
        ../../users/dave.nix
    ];

    # Bootloader.
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.useOSProber = true;

    networking.hostName = "nixos";

    # GNOME / GDM
    security.pam.services.gdm.fprintAuth = true;
    security.pam.services.gdm-password.fprintAuth = true;

    system.stateVersion = "25.11";
}
