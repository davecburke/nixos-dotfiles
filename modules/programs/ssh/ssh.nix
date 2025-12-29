{ config, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    
    # Disable default config and set defaults explicitly in matchBlocks
    enableDefaultConfig = false;
    
    # SSH host configurations
    # Default settings applied to all hosts via wildcard match
    # Host-specific configurations override defaults as needed
    matchBlocks = {
      # Default settings for all hosts
      "*" = {
        # Control master for connection multiplexing (faster subsequent connections)
        # controlMaster = "auto";
        # controlPath = "~/.ssh/control-%r@%h:%p";
        # controlPersist = "10m";
        
        # Compression for slower connections
        compression = false;
        
        # Forward agent (be careful with this - only enable if needed)
        forwardAgent = false;
        
        # Server alive settings
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
      
      # Host-specific configurations
      "github-personal" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_rsa_personal";
        identitiesOnly = true;
      };
      
      "github-work" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_rsa";
        identitiesOnly = true;
      };
      
      "simplelogin" = {
        hostname = "65.109.14.222";
        user = "root";
        identityFile = "~/.ssh/id_rsa_personal";
        identitiesOnly = true;
      };
      
      "vultr" = {
        hostname = "67.219.101.55";
        user = "root";
        identityFile = "~/.ssh/id_rsa_personal";
        identitiesOnly = true;
      };
      
      "contabo" = {
        hostname = "207.180.252.247";
        user = "root";
        identityFile = "~/.ssh/id_rsa_personal";
        identitiesOnly = true;
      };
      
      "cr10" = {
        hostname = "192.168.86.82";
        user = "pi";
        identityFile = "~/.ssh/id_rsa_personal";
        identitiesOnly = true;
      };
      
      "klipper" = {
        hostname = "192.168.86.277";
        user = "pi";
        identityFile = "~/.ssh/id_rsa_personal";
        identitiesOnly = true;
      };
      
      "caddy" = {
        hostname = "192.168.86.70";
        user = "root";
        identityFile = "~/.ssh/id_rsa_personal";
        identitiesOnly = true;
      };
      
      "opnsense" = {
        hostname = "192.168.86.1";
        user = "dave";
        identityFile = "~/.ssh/id_rsa_personal";
        identitiesOnly = true;
      };
    };
  };

}

