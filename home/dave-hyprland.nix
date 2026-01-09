{ config, pkgs, pkgsUnstable ? pkgs, ... }:

{
    imports = [
        ../modules/programs/ssh/ssh.nix
    ];
    
    home.username = "dave";
    home.homeDirectory = "/home/dave";
    programs.git = {
        enable = true;
        settings = {
            user = {
                name = "David Burke";
                email = "david@burke.chat";
            };
        };
    };
    home.stateVersion = "25.11";

    home.packages = [
        pkgs.google-chrome
        pkgs.lazygit
        pkgsUnstable.vscode
        pkgs.ksnip
        pkgsUnstable.code-cursor
        pkgs.meld
        pkgs.firefox-devedition
        pkgs.postman
        pkgs.brave
        pkgs.slack
        pkgs.libreoffice
        pkgs.virt-viewer
    ];


    xdg.configFile."hypr" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/window-managers/hyprland/config/hypr;
        recursive = true;
        force = true;
    };

    xdg.configFile."waybar" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/window-managers/hyprland/config/waybar;
        recursive = true;
        force = true;
    };

    xdg.configFile."foot" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/window-managers/hyprland/config/foot;
        recursive = true;
        force = true;
    };

    programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        oh-my-zsh = {
            enable = true;
            #theme = "robbyrussell"; # blinks is also really nice
            theme = "";
            extraConfig = ''
                zstyle :omz:plugins:ssh-agent identities id_rsa_personal id_rsa
            '';
            plugins = [ "command-not-found ssh-agent" ];
        };

        plugins = [
            {
                name = "powerlevel10k";
                src = pkgs.zsh-powerlevel10k;
                file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
            }
        ];

        initContent = ''
        # Extra Zsh config here
        # Add custom PATHs
        export PATH="$HOME/.local/bin:$PATH"
        export PATH="$HOME/.pyenv/shims:$PATH"
        export PATH="$HOME/.npm-global/bin:$PATH"
        eval "$(pyenv init --path)"
        fastfetch
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
        '';
    };
    
    home.sessionVariables = {
        NPM_CONFIG_PREFIX = "$HOME/.npm-global";
        JAVA_HOME = "${pkgs.jdk21_headless}";
    };

    home.sessionPath = [
        "$HOME/.npm-global/bin"
    ];

    # #feh
    # home.file.".fehbg" = {
    #     source = ./scripts/.fehbg;
    #     executable = true;
    # };

    #greenclip
    home.file.".config/greenclip.toml".source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/programs/greenclip/greenclip.toml;
    home.file.".config/greenclip/launch.sh" = {
        source = ../modules/programs/greenclip/launch.sh;
        executable = true;
    };

    #zsh powerlevel10k config
    home.file.".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/programs/zsh/config/.p10k.zsh;

    #dunst
    xdg.configFile."dunst" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/programs/dunst/config;
        recursive = true;
        force = true;
    };

    #polybar
    # xdg.configFile."polybar" = {
    #     source = config.lib.file.mkOutOfStoreSymlink "/home/dave/nixos-dotfiles/modules/programs/polybar/config";
    #     recursive = true;
    #     force = true;
    # };

    #rofi
    xdg.configFile."rofi" = {
        source = config.lib.file.mkOutOfStoreSymlink "/home/dave/nixos-dotfiles/modules/programs/rofi/config";
        recursive = true;
        force = true;
    };

    #TODO: Make this optional only if i3 is selected as the window manager
    #i3
    # xdg.configFile."i3" = {
    #     source = config.lib.file.mkOutOfStoreSymlink "/home/dave/nixos-dotfiles/modules/window-managers/i3/config";
    #     recursive = true;
    #     force = true;
    # };
}
