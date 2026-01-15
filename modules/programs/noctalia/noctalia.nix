{ pkgs, inputs, pkgsUnstable ? pkgs, ... }:
{
    # Enable evolution-data-server for calendar events support
    services.gnome.evolution-data-server.enable = true;

    environment.systemPackages = with pkgsUnstable; [
        gnome-keyring
    ];

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}