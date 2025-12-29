{ pkgs, config, lib, ... }:


{
    imports = [
        ../../programs/dunst/dunst.nix
        ../../programs/rofi/rofi.nix
        ../../programs/polybar/polybar.nix
        ../../programs/greenclip/greenclip.nix
    ];

    services.xserver.windowManager.i3.enable = true;
    programs.i3lock.enable = true;
    security.pam.services.i3lock.enable = true;

    environment.systemPackages = with pkgs; [
        i3  # i3 now includes gaps support (i3-gaps has been merged into i3)
        i3lock-color
        numlockx
        xautolock
        betterlockscreen
        dmenu
        feh
        picom
        dex  # XDG autostart
        xss-lock  # Screen locker
        networkmanagerapplet  # nm-applet for NetworkManager
        polkit_gnome  # polkit-gnome-authentication-agent-1
        nautilus  # File manager (moved from gnome.nautilus)
        gnome-calculator  # Calculator (moved from gnome.gnome-calculator)
        #rofi-power-menu  # Power menu for rofi
    ];
}
