{
    description = "NixOS Configs";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-25.11";
        nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager/release-25.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        stylix = {
            url = "github:danth/stylix/release-25.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        noctalia = {
            url = "github:noctalia-dev/noctalia-shell";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };
    };

    outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, stylix, noctalia, ... }@inputs: {
        nixosConfigurations.nixos-i3-gnome = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                ./configuration.nix
                ./hosts/zbook/default.nix
                ./modules/desktop-managers/gnome.nix
                ./modules/display-managers/gdm.nix
                ./modules/window-managers/i3/i3.nix
                ./modules/core/fonts.nix
                ./modules/themes/nordic.nix
                ./modules/core/programs.nix
                ./modules/core/audio.nix
                ./modules/core/locale.nix
                ./modules/core/networking.nix
                ./modules/core/nix.nix
                ./modules/core/printing.nix
                ./modules/core/system-packages.nix
                ./modules/core/unfree.nix
                ./modules/core/xserver.nix
                home-manager.nixosModules.home-manager
                {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.dave = { config, pkgs, ... }: import ./home/dave-i3.nix {
                            inherit config pkgs;
                            pkgsUnstable = import nixpkgs-unstable {
                                system = "x86_64-linux";
                                config.allowUnfree = true;
                            };
                        };
                        backupFileExtension = "backup";
                    };
                }
            ];
        };
        nixosConfigurations.nixos-hyprland = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                ./hosts/zbook/default.nix
                ./modules/display-managers/gdm.nix
                ./modules/window-managers/hyprland/hyprland.nix
                ./modules/core/fonts.nix
                ./modules/core/programs.nix
                ./modules/core/audio.nix
                ./modules/core/locale.nix
                ./modules/core/networking.nix
                ./modules/core/nix.nix
                ./modules/core/printing.nix
                ./modules/core/system-packages.nix
                ./modules/core/unfree.nix
                ./modules/programs/dunst/dunst.nix
                ./modules/programs/rofi/rofi.nix
                home-manager.nixosModules.home-manager
                {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users.dave = { config, pkgs, ... }: import ./home/dave-hyprland.nix {
                            inherit config pkgs;
                            pkgsUnstable = import nixpkgs-unstable {
                                system = "x86_64-linux";
                                config.allowUnfree = true;
                            };
                        };
                        backupFileExtension = "backup";
                    };
                }
            ];
        };
        nixosConfigurations.nixos-niri = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
                inherit inputs;
                pkgsUnstable = import nixpkgs-unstable {
                    system = "x86_64-linux";
                    config.allowUnfree = true;
                };
            };
            modules = [
                ./hosts/zbook/default.nix
                ./modules/display-managers/gdm.nix
                ./modules/window-managers/niri/niri.nix
                ./modules/core/fonts.nix
                ./modules/core/programs.nix
                ./modules/core/audio.nix
                ./modules/core/locale.nix
                ./modules/core/networking.nix
                ./modules/core/nix.nix
                ./modules/core/printing.nix
                ./modules/core/system-packages.nix
                ./modules/core/unfree.nix
                ./modules/core/bluetooth.nix
                ./modules/core/power.nix
                # ./modules/programs/noctalia/noctalia.nix
                ./modules/themes/stylix/stylix-nord.nix
                ./modules/themes/nordic.nix
                # ./modules/programs/fastfetch/fastfetch.nix
                # ./modules/programs/nvim/nvim.nix
                # ./modules/themes/gtk.nix
                home-manager.nixosModules.home-manager
                {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        extraSpecialArgs = { 
                            inherit inputs;
                            pkgsUnstable = import nixpkgs-unstable {
                                system = "x86_64-linux";
                                config.allowUnfree = true;
                            };
                        };
                        users.dave = { config, pkgs, inputs, pkgsUnstable, ... }: import ./home/dave-niri.nix {
                            inherit config pkgs inputs pkgsUnstable;
                        };
                        backupFileExtension = "hm-backup";
                        overwriteBackup = true;
                    };
                }
            ];
        };
    };
}
