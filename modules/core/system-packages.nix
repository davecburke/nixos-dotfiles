{ pkgs, ... }:

{
    programs.git.enable = true;
    environment.systemPackages = with pkgs; [
        killall
        fastfetch
        git
        curl
        wget
    ];
}