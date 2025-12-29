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
    ];
}