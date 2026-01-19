{ config, pkgs, pkgsUnstable ? pkgs, inputs, ... }:

{
    imports = [
        ../modules/programs/ssh/ssh.nix
        ../modules/programs/alacritty/alacritty.nix
        ../modules/programs/noctalia/noctalia.nix
        ../modules/programs/fastfetch/fastfetch.nix
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
        # pkgsUnstable.neovim
    ];

    services.hyprpolkitagent.enable = true;
    services.gnome-keyring.enable = true;
    
    # Systemd user service for noctalia-shell to ensure it's always running
    # This fixes the issue where keybinds don't work after rebuild switch
    # The service will automatically start on login and restart if it crashes
    systemd.user.services.noctalia-shell =
    let
        noctaliaShell = inputs.noctalia.packages.x86_64-linux.default;
    in
    {
        Unit = {
            Description = "Noctalia Shell";
            After = [ "graphical-session.target" "graphical-session-pre.target" ];
            PartOf = [ "graphical-session.target" ];
        };
        Service = {
            Type = "simple";
            ExecStart = "${noctaliaShell}/bin/noctalia-shell";
            Restart = "on-failure";
            RestartSec = 5;
            # Environment is automatically inherited from user session
        };
        Install = {
            WantedBy = [ "graphical-session.target" ];
        };
    };
    
    services.swayidle =
    let
        noctaliaShell = inputs.noctalia.packages.x86_64-linux.default;
        # Lock command - use full path so swayidle can find it
        lock = "${noctaliaShell}/bin/noctalia-shell ipc call lockScreen lock";
        # TODO: modify "display" function based on your window manager
        # Sway
        #display = status: "${pkgs.sway}/bin/swaymsg 'output * power ${status}'";
        # Hyprland
        # display = status: "hyprctl dispatch dpms ${status}";
        # Niri
        display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
    in
    {
        enable = true;
        timeouts = [
            {
                timeout = 300; # in seconds
                command = "${pkgs.libnotify}/bin/notify-send 'Locking in 5 seconds' -t 5000";
            }
            {
                timeout = 305;
                command = lock;
            }
            {
                timeout = 365;
                command = display "off";
                resumeCommand = display "on";
            }
            {
                timeout = 370;
                command = "${pkgs.systemd}/bin/systemctl suspend";
            }
        ];
        events = [
            {
                event = "before-sleep";
                # adding duplicated entries for the same event may not work
                command = (display "off") + "; " + lock;
            }
            {
                event = "after-resume";
                command = display "on";
            }
            {
                event = "lock";
                command = (display "off") + "; " + lock;
            }
            {
                event = "unlock";
                command = display "on";
            }
        ];
    };

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

    #niri
    xdg.configFile."niri" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/window-managers/niri/config;
        recursive = true;
        force = true;
    };

    #cliphist
    xdg.configFile."cliphist/launch.sh" = {
        source = ../modules/programs/cliphist/launch.sh;
        executable = true;
    };
    xdg.configFile."cliphist/static_entries.txt" = {
        source = ../modules/programs/cliphist/static_entries.txt;
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

        #zsh powerlevel10k config
    home.file.".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/programs/zsh/config/.p10k.zsh;
    
    home.sessionVariables = {
        NPM_CONFIG_PREFIX = "$HOME/.npm-global";
        JAVA_HOME = "${pkgs.jdk21_headless}";
    };

    home.sessionPath = [
        "$HOME/.npm-global/bin"
    ];
}
