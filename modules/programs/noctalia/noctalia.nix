{ pkgs, inputs, pkgsUnstable ? pkgs, config, ... }:
{
    home.packages = with pkgsUnstable; [
        gnome-keyring
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    xdg.configFile."noctalia" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/programs/noctalia/config;
        recursive = true;
        force = true;
    };
}