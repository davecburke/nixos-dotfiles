{ pkgs, pkgsUnstable ? pkgs, config, ... }:

{
    environment.systemPackages = [
        pkgsUnstable.prusa-slicer
    ];
}