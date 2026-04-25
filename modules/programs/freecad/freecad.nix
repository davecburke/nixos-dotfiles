{ pkgs, pkgsUnstable ? pkgs, config, ... }:

{
    environment.systemPackages = [
        pkgsUnstable.freecad
    ];
}