{ ... }:
{
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

    # Reduce systemd stop timeout to prevent long shutdown hangs
    # (fixes "A stop job is running for User Manager for UID 1000")
    systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
}  