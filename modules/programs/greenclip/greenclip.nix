{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        haskellPackages.greenclip
    ];
}