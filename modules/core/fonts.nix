{ pkgs, ... }:

{
    fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        unifont
        siji
        font-awesome
        font-awesome_6
        weather-icons
    ];
}