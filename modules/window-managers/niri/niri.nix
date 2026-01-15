{ pkgs,... }:

{
    programs.niri.enable = true;
    programs.nm-applet.enable = true;

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
