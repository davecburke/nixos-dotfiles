{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        killall
        gitFull
        curl
        wget
    ];
}