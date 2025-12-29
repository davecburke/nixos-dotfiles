{
    description = "NixOS Configs";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-25.11";
        home-manager = {
        url = "github:nix-community/home-manager/release-25.11";
        inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, home-manager, ... }: {
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
                        users.dave = import ./home.nix;
                        backupFileExtension = "backup";
                    };
                }
            ];
        };
    };
}
