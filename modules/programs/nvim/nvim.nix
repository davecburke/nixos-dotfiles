{ pkgs, pkgsUnstable ? pkgs, ... }:

{
    environment.systemPackages = [
        pkgsUnstable.neovim
    ];
}