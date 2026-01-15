{ pkgs, ... }:

{
    services.displayManager.gdm.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true;
    security.pam.services.login.enableGnomeKeyring = true;
}