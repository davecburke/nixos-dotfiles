{ pkgs,... }:

{
    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
        foot
        alacritty
        waybar
        hyprpaper
        wofi
        cliphist
        wl-clipboard
        hyprlock
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
    ];
}
