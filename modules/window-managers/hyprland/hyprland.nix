{ pkgs,... }:

{
    programs.hyprland = {
        enable = true;
        xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
        foot
        kitty
        waybar
        hyprpaper
    ];
}