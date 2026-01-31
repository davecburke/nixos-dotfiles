{ pkgs, lib, inputs, pkgsUnstable ? pkgs, config, configName ? "nixos-niri-zbook", ... }:
let
  hostId = lib.removePrefix "nixos-niri-" configName;
  repoPath = "/home/dave/nixos-dotfiles/modules/programs/noctalia";
  outOfStoreConfigDir = "${repoPath}/config-${hostId}";

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
  configDir = pkgs.runCommand "noctalia-config-${hostId}" {
    src = ./config;
    mergedSettings = mergedSettingsFile;
  } ''
    mkdir -p $out
    cp -r $src/* $out/ 2>/dev/null || true
    rm -f $out/settings.json
    cp $mergedSettings $out/settings.json
  '';
in
{
  home.packages = with pkgsUnstable; [
    gnome-keyring
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Copy the built config (with merged settings.json) into the repo so we can symlink out-of-store.
  home.activation.noctaliaConfigDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -rf ${outOfStoreConfigDir}
    cp -r ${configDir} ${outOfStoreConfigDir}
  '';

  xdg.configFile."noctalia" = {
    source = config.lib.file.mkOutOfStoreSymlink outOfStoreConfigDir;
    recursive = true;
    force = true;
  };
}
