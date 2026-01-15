{ pkgs, inputs, pkgsUnstable ? pkgs, config, ... }:
{
    # Enable evolution-data-server for calendar events support
    services.gnome.evolution-data-server.enable = true;

    environment.systemPackages = with pkgsUnstable; [
        gnome-keyring
        inputs.noctalia.packages.${config.nixpkgs.system}.default
    ];

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}