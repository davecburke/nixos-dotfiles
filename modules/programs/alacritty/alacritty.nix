{ pkgs, config, ... }:

{
    home.packages = with pkgs; [
        alacritty
    ];

    xdg.configFile."alacritty" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/programs/alacritty/config;
        recursive = true;
        force = true;
    };

}