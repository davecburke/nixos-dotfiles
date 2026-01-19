{ pkgs, config, ... }:

{
    programs.niri.enable = true;
    programs.nm-applet.enable = true;

    # Enable evolution-data-server for calendar events support (needed for noctalia)
    services.gnome.evolution-data-server.enable = true;

    # Enable xdg.portal for desktop integration
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    environment.systemPackages = with pkgs; [
        #ghostty
        # foot
        alacritty
        # waybar
        # hyprpaper
        # wofi
        cliphist
        wl-clipboard
        # hyprlock
        grimblast
        # swappy
        grim
        slurp
        niri
        xwayland-satellite
        fuzzel
        swaybg
        swaylock
        satty
        gvfs
    ];
}
