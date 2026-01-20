{ pkgs, ... }:
{
    # Enable GVFS service for Nautilus network support and remote file systems
    services.gvfs.enable = true;

    # Enable Avahi for network device discovery (mDNS/DNS-SD)
    # This allows Nautilus to discover Synology NAS and other network devices
    services.avahi = {
        enable = true;
        nssmdns4 = true;  # Use mDNS for hostname resolution
    };

    # # GNOME Online Accounts for Google Drive and other cloud services
    # services.gnome.gnome-online-accounts.enable = true;
    
    # # Accounts daemon required for GNOME Online Accounts
    # services.accounts-daemon.enable = true;

    # # Dconf backend required for GNOME Online Accounts configuration
    # programs.dconf.enable = true;

    # Optional: Install Samba client utilities for manual mounting if needed
    environment.systemPackages = with pkgs; [
        cifs-utils  # For mounting SMB/CIFS shares
    ];
}
