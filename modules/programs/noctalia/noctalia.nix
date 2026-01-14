{ pkgs, inputs, pkgsUnstable ? pkgs, ... }:
{
    # Enable evolution-data-server for calendar events support
    services.gnome.evolution-data-server.enable = true;

    environment.systemPackages = with pkgsUnstable; [
        (noctalia-shell.override { calendarSupport = true; })
        evolution
        evolution-ews
        evolution-data-server
        gnome-keyring
    ];
}