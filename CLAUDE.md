# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Apply Commands

Apply config for a specific host:
```bash
sudo nixos-rebuild switch --flake ~/nixos-dotfiles/.#nixos-niri-zbook
sudo nixos-rebuild switch --flake ~/nixos-dotfiles/.#nixos-niri-probook
sudo nixos-rebuild switch --flake ~/nixos-dotfiles/.#nixos-i3-gnome
sudo nixos-rebuild switch --flake ~/nixos-dotfiles/.#nixos-hyprland
```

Test build without switching (dry run):
```bash
sudo nixos-rebuild dry-build --flake ~/nixos-dotfiles/.#nixos-niri-zbook
```

Update flake inputs (nixpkgs, home-manager, etc.):
```bash
sudo nix flake update
```

Garbage collect old generations:
```bash
sudo nix-collect-garbage -d
```

Roll back if something breaks:
```bash
sudo nixos-rebuild switch --rollback
```

## Architecture

This is a NixOS flake-based dotfiles repo supporting multiple hosts and desktop configurations. The entry point is `flake.nix`, which defines four `nixosConfigurations`:

- `nixos-niri-zbook` — HP ZBook laptop, Niri compositor (primary/active config)
- `nixos-niri-probook` — HP ProBook laptop, Niri compositor
- `nixos-i3-gnome` — ZBook, i3 window manager with GNOME
- `nixos-hyprland` — ZBook, Hyprland compositor

### Key structural patterns

**NixOS modules** live in `modules/` and are imported explicitly in `flake.nix` per configuration:
- `modules/core/` — system-level config (audio, networking, locale, fonts, packages, printing, etc.)
- `modules/window-managers/` — per-WM config including bundled app configs (waybar, foot terminal, hyprland.conf, niri config)
- `modules/programs/` — individual program configs (noctalia, alacritty, dunst, rofi, polybar, etc.)
- `modules/themes/` — GTK themes, Stylix theming, wallpapers
- `modules/display-managers/` and `modules/desktop-managers/` — GDM, GNOME

**Host-specific hardware** is in `hosts/<hostname>/` (default.nix + hardware-configuration.nix).

**Home Manager** is integrated as a NixOS module. Home configs are in `home/`:
- `dave-niri.nix` — used by both niri configs; receives `configName` to differentiate hosts
- `dave-hyprland.nix` and `dave-i3.nix` — for their respective WMs

### Multi-host pattern in home config

`home/dave-niri.nix` uses `configName` (e.g. `"nixos-niri-zbook"`) passed via `extraSpecialArgs` to derive a `hostId` (`zbook` or `probook`). This is used to inject host-specific niri output blocks (monitor layout) into `config.kdl` at activation time via an awk script, while preserving live user edits outside those markers.

### Unstable packages

`nixpkgs-unstable` is instantiated inline in `flake.nix` and passed as `pkgsUnstable` via `specialArgs`/`extraSpecialArgs`. Use `pkgsUnstable.<package>` in home configs for packages that need a newer version than the stable channel (currently nixos-25.11).

### Noctalia Shell

Noctalia is a Wayland shell/bar used on the niri configs. It is run as a systemd user service defined in `home/dave-niri.nix`. Its config lives in `modules/programs/noctalia/config/` (and a `config-zbook/` variant). The noctalia input is pinned to nixpkgs-unstable and built with `calendarSupport = true`.

### Stylix

Stylix is used for system-wide theming on the niri configs (`modules/themes/stylix/`). It styles GTK, Firefox (via `stylix.targets.firefox.profileNames`), and terminal apps.
