{ pkgs, lib, inputs, pkgsUnstable ? pkgs, config, configName ? "nixos-niri-zbook", ... }:
let
  hostId = lib.removePrefix "nixos-niri-" configName;
  repoPath = "/home/dave/nixos-dotfiles/modules/programs/noctalia";
  configDir = "${repoPath}/config";

  baseSettings = lib.importJSON ./config/settings.json;
  overridesByHost = {
    zbook = {
      bar = { monitors = [ "DP-2" ]; };
      desktopWidgets = {
        enabled = false;
        gridSnap = false;
        monitorWidgets = [
          {
            name = "DP-2";
            widgets = [
              { id = "Weather"; showBackground = true; x = 100; y = 300; }
            ];
          }
        ];
      };
      notifications = { monitors = [ "DP-2" ]; };
      osd = { monitors = [ "DP-2" ]; };
    };
    probook = {
      bar = { monitors = [ "HDMI-A-1" ]; };
      desktopWidgets = {
        enabled = false;
        gridSnap = false;
        monitorWidgets = [
          {
            name = "HDMI-A-2";
            widgets = [
              { id = "Weather"; showBackground = true; x = 100; y = 300; }
            ];
          }
        ];
      };
      notifications = { monitors = [ "HDMI-A-1" ]; };
      osd = { monitors = [ "HDMI-A-1" ]; };
    };
  };
  overrideSettings = overridesByHost.${hostId} or { };
  mergedSettings = lib.recursiveUpdate baseSettings overrideSettings;
  mergedSettingsFile = pkgs.writeText "noctalia-settings.json" (builtins.toJSON mergedSettings);
in
{
  home.packages = with pkgsUnstable; [
    gnome-keyring
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Write the merged settings.json to the repo's config/ directory before symlinking.
  home.activation.noctaliaMergedSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cp ${mergedSettingsFile} ${configDir}/settings.json
  '';

  xdg.configFile."noctalia" = {
    source = config.lib.file.mkOutOfStoreSymlink configDir;
    recursive = true;
    force = true;
  };
}
