{ pkgs, ... }:

{
    #programs.rofi.enable = true;

    environment.systemPackages = with pkgs; [
        rofi
        rofi-power-menu
    ];
}