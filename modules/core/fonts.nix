{ pkgs, ... }:

{
    fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.meslo-lg
        unifont
        siji
        font-awesome
        font-awesome_6
        weather-icons
    ];
}