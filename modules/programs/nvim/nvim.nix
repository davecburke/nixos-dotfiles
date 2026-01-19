{ pkgs, pkgsUnstable ? pkgs, config, ... }:

{
    environment.systemPackages = [
        pkgsUnstable.neovim
        pkgs.fzf
        pkgs.ripgrep
        pkgs.fd
        # Dependencies for nvim-treesitter
        pkgs.tree-sitter  # tree-sitter-cli for building parsers
        pkgs.gcc         # C compiler for building tree-sitter parsers
        # Note: tar and curl are typically already available in the system PATH
    ];

    xdg.configFile."nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink /home/dave/nixos-dotfiles/modules/programs/nvim/config;
        recursive = true;
        force = true;
    };
}