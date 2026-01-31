{ config, pkgs, pkgsUnstable ? pkgs, inputs, configName ? "nixos-niri-zbook", ... }:

let
  lib = pkgs.lib;
  hostId = lib.removePrefix "nixos-niri-" configName;
  # Use home directory so path works on any machine (zbook, probook, etc.)
  configDir = "${config.home.homeDirectory}/nixos-dotfiles/modules/window-managers/niri/config";
  
  # Host-specific output blocks for niri config
  outputsByHost = {
    zbook = ''
output "eDP-1" {
	mode "1920x1080@60.000"
	scale 1
	position x=-1920 y=0
}
output "DP-2" {
	mode "2560x1080@60.000"
	position x=0 y=0
}'';
    probook = ''
output "eDP-1" {
	mode "1920x1080@60.000"
	scale 1
	position x=-1920 y=0
}
output "HDMI-A-1" {
	mode "2560x1080@60.000"
	position x=0 y=0
}'';
  };
  
  hostOutputs = outputsByHost.${hostId} or outputsByHost.zbook;
  baseConfig = builtins.readFile ../modules/window-managers/niri/config/config.kdl;
  
  # Replace the section between markers with host-specific outputs
  mergedConfig = 
    let
      parts = lib.splitString "// BEGIN_HOST_OUTPUTS" baseConfig;
      beforeMarker = builtins.head parts;
      afterFirstMarker = builtins.elemAt parts 1;
      afterParts = lib.splitString "// END_HOST_OUTPUTS" afterFirstMarker;
      afterMarker = builtins.elemAt afterParts 1;
    in
      beforeMarker + "// BEGIN_HOST_OUTPUTS\n" + hostOutputs + "\n// END_HOST_OUTPUTS" + afterMarker;
  
  mergedConfigFile = pkgs.writeText "niri-config.kdl" mergedConfig;
in

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
        pkgs.loupe
        pkgs.mpv
        # pkgs.gnome-control-center  # For Online Accounts (Google Drive, etc.)
        # pkgsUnstable.neovim
        # pkgsUnstable.dms-shell  # Dark Material Shell
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

    stylix.targets.firefox.profileNames = [ "default" "dev-edition-default" ];

    xdg.configFile."themes" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/themes;
        recursive = true;
        force = true;
    };

    # Write the merged niri config.kdl to the repo before symlinking.
    # If this doesn't run during nixos-rebuild switch, run: systemctl --user start home-manager-dave.service
    home.activation.niriMergedConfig = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        set -e
        mkdir -p ${configDir}
        cp ${mergedConfigFile} ${configDir}/config.kdl
        echo "Niri config updated for host: ${hostId}"
    '';

    #niri
    xdg.configFile."niri" = {
        source = config.lib.file.mkOutOfStoreSymlink configDir;
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
        eval "$(pyenv init --path)"
        fastfetch
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
        '';
    };

        #zsh powerlevel10k config
    home.file.".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/programs/zsh/config/.p10k.zsh;
    home.file.".npmrc".text = ''
        prefix=${config.home.homeDirectory}/.local
    '';

    home.activation.ensureLocalBin = ''
  	mkdir -p "$HOME/.local/bin"
	'';
    
    home.sessionVariables = {
        # npm puts executables in $PREFIX/bin, so use .local not .local/bin
        NPM_CONFIG_PREFIX = "$HOME/.local";
        JAVA_HOME = "${pkgs.jdk21}";
    };

    home.sessionPath = [
        "$HOME/.local/bin"
    ];
}