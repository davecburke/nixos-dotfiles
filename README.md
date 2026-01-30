# NixOS config with desktop profiles

## Setup
### 1. Install NixOS and follow the setup wizard. (nixos-install). User name is dave. This will generate:
```bash
/etc/nixos/configuration.nix
/etc/nixos/hardware-configuration.nix
```

### 2. After rebooting into your new system:
```bash
cd /etc/nixos
sudo nano configuration.nix
```

Add git and enable OpenSSH
```nixos
environment.systemPackages = with pkgs; [
#  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
#  wget
    git
];

# Enable the OpenSSH daemon.
services.openssh.enable = true;
```
*NB. You can now SSH into the new install*

Rebuild nix
```bash
sudo nixos-rebuild switch
```
Optional config backup
```bash
sudo mv configuration.nix configuration.backup.nix # optional backup
```
### 3. Add private keys and change permissions
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa ~/.ssh/id_rsa_personal
```
### 4. Clone the repo
Add personal identity
```bash
eval "$(ssh-agent -s)"
ssh-add -D #remove identities
ssh-add ~/.ssh/id_rsa_personal
```
Clone the repo
```bash
cd ~
git clone https://github.com/davecburke/nixos-dotfiles.git 
```

### 5. Move the generated hardware-configuration.nix to your flake's expected path:
```bash
sudo mv /etc/nixos/hardware-configuration.nix ~/nixos-dotfiles/hosts/hardware-configuration.nix
```
Change ownership
```bash
sudo chown dave:users ~/nixos-dotfiles/hosts/hardware-configuration.nix
```

### 6. Build and apply your config:
```bash
sudo nixos-rebuild switch --flake ~/nixos-dotfiles/.#nixos-i3-gnome
```

## After Setup Instructions
### 1. Install Saleforce CLI
```bash
npm install -g @salesforce/cli
```
## Nix Commands
```bash
sudo nixos-rebuild switch --flake ~/nixos-dotfiles/.#nixos-i3-gnome
```
```bash
sudo nix-collect-garbage -d
```
## Check for updates
```bash
sudo nix flake update
```
This updates flake.lock with newer versions of nixpkgs and other inputs.
To see what changed:
```bash
git diff flake.lock
```
Apply updates
```bash
sudo nixos-rebuild switch --flake ~/nixos-dotfiles/.#nixos-i3-gnome
```
See current NixOS version
```bash
nixos-version
```
List generations (rollback-friendly)
```bash
nixos-rebuild list-generations
```
Roll back if something breaks
```bash
sudo nixos-rebuild switch --rollback
```
## ZBOOK
### Fingerprint
Enable firmware updates
```bash
fwupdmgr get-devices
fwupdmgr enable-remote lvfs-testing
fwupdmgr refresh --force
fwupdmgr get-updates
fwupdmgr update
```
Reboot
```bash
fprintd-enroll
```
You want to end with:
```bash
Enroll result: enroll-completed
```
Verify
```bash
fprintd-list $USER
```
Expected:
```bash
right-index-finger
```