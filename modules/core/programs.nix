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
        jdk21_headless
        usbutils
    ];
    # Create /etc/jvm/java-21 -> <nix store path to the JDK>
    environment.etc."jvm/java-21".source = pkgs.jdk21_headless;
}