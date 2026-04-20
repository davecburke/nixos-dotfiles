{ pkgs, ... }:
{
    services.printing.enable = true;

    # Scanning (network MFPs, eSCL/AirScan)
    hardware.sane = {
        enable = true;
        extraBackends = [
            pkgs.sane-airscan
            pkgs.brscan5
        ];
    };

    # Discovery for network devices (mDNS/DNS-SD), often needed for AirScan.
    services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
    };

    environment.systemPackages = with pkgs; [
        simple-scan
    ];
}
