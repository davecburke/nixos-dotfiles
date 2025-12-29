{ pkgs, ... }:

{
    # services.dunst.enable = true;

    environment.systemPackages = with pkgs; [
        dunst
        libnotify
    ];
}