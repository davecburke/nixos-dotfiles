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
  overrideSettingsFile = pkgs.writeText "noctalia-overrides.json" (builtins.toJSON overrideSettings);

  # Deep-merge: only monitor-related overrides are layered on top of live config.
  mergeScript = ''
    def deep_merge(a; b):
      a as $a | b as $b
      | if $b == null then $a
        elif ($a|type) == "object" and ($b|type) == "object"
        then ([$a, $b] | add | keys_unsorted) as $keys
        | {} | reduce $keys[] as $k (.; .[$k] = deep_merge($a[$k]; $b[$k]))
        else $b
        end;
    deep_merge(.[0]; .[1])
  '';
  mergeScriptFile = pkgs.writeText "noctalia-merge.jq" mergeScript;
in
{
  home.packages = with pkgsUnstable; [
    gnome-keyring
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Read live config, apply only monitor overrides (host-specific), write back.
  home.activation.noctaliaMergedSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    liveConfig="${configDir}/settings.json"
    overridesFile="${overrideSettingsFile}"
    jq=${pkgs.jq}/bin/jq

    if [ ! -f "$liveConfig" ]; then
      cp ${mergedSettingsFile} "$liveConfig"
    else
      tmp=$(mktemp)
      if $jq -s -f ${mergeScriptFile} "$liveConfig" "$overridesFile" > "$tmp"; then
        mv "$tmp" "$liveConfig"
      else
        rm -f "$tmp"
        echo "noctalia: jq merge failed, leaving settings.json unchanged" >&2
        exit 1
      fi
    fi
  '';

  xdg.configFile."noctalia" = {
    source = config.lib.file.mkOutOfStoreSymlink configDir;
    recursive = true;
    force = true;
  };
}
