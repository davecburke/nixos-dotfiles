{ pkgs, config, ... }:

{
    home.packages = with pkgs; [
        fastfetch
    ];

    xdg.configFile."fastfetch" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/programs/fastfetch/config;
        recursive = true;
        force = true;
    };
}