{ pkgs, ... }:

{
    services.xserver.enable = true;

    services.xserver.xkb = {
        layout = "au";
        variant = "";
    };
}