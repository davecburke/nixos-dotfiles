{ pkgs, ... }:

{
    programs.firefox.enable = true;
    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
        git
        pyenv
        jq
        nodejs
        python3
        jdk21
        usbutils
        (writeShellApplication {
            name = "ns";
            runtimeInputs = with pkgs; [
                fzf
                nix-search-tv
            ];
            text = builtins.readFile "${nix-search-tv.src}/nixpkgs.sh";
            excludeShellChecks = [ "SC2016" ];
        })
    ];

    programs.npm.settings = {
        prefix = "$HOME/.local/bin";
    };
}