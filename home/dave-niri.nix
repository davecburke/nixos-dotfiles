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
        # pkgs.ksnip
        pkgsUnstable.code-cursor
        pkgs.meld
        pkgs.firefox-devedition
        pkgs.postman
        pkgs.brave
        pkgs.slack
        pkgs.libreoffice
        pkgs.virt-viewer
        # pkgs.xfce.thunar
        pkgs.nautilus
        pkgs.qalculate-gtk
        pkgs.quickshell
        pkgs.seahorse  # For managing gnome-keyring passwords
        pkgs.gnome-text-editor
        pkgs.gvfs
    ];

    services.hyprpolkitagent.enable = true;
    services.gnome-keyring.enable = true;

    # programs.firefox = {
    #     enable = true;

    #     # profiles = {
    #     #     default = {
    #     #         id = 0;
    #     #         # bookmarks, extensions, search engines...
    #     #     };
    #     #     dev-edition-default = {
    #     #         id = 1;
    #     #         # bookmarks, extensions, search engines...
    #     #     };
    #     # };
    # };

    stylix.targets.firefox.profileNames = [ "default" "dev-edition-default" ];

    xdg.configFile."themes" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/themes;
        recursive = true;
        force = true;
    };

    xdg.configFile."noctalia" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/programs/noctalia/config;
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

    #cliphist
    home.file.".config/cliphist/launch.sh" = {
        source = ../modules/programs/cliphist/launch.sh;
        executable = true;
    };
    home.file.".config/cliphist/static_entries.txt" = {
        source = ../modules/programs/cliphist/static_entries.txt;
    };

    #zsh powerlevel10k config
    home.file.".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/programs/zsh/config/.p10k.zsh;

    #niri
    xdg.configFile."niri" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/window-managers/niri/config;
        recursive = true;
        force = true;
    };
}
