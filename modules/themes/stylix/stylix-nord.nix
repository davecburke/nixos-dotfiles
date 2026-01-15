{ inputs, pkgs, ... }:

{
    imports = [
        inputs.stylix.nixosModules.stylix
    ];

    stylix = {
        enable = true;

        # Nord palette - using base16-schemes package
        base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";

        image = ../wallpaper/current.jpg;

        fonts = {
        serif = {
            package = pkgs.noto-fonts;
            name = "Noto Serif";
        };
        sansSerif = {
            package = pkgs.noto-fonts;
            name = "Noto Sans";
        };
        monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
        };
        emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
        };
    };

    cursor = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Ice";
            size = 24;
        };
    };
}
