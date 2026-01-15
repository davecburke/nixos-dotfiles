{ ... }:
{
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.download-buffer-size = 134217728; # 128 MB
}
