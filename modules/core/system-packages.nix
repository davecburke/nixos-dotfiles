{ pkgs, ... }:

{
    programs.git.enable = true;
    environment.systemPackages = with pkgs; [
        killall
        git
        curl
        wget
    ];
}