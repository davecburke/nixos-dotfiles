{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        nordic
        papirus-icon-theme
    ];
}