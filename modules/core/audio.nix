{ pkgs, ... }:
{
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };

    environment.systemPackages = with pkgs; [
        libcanberra
        libcanberra-gtk3
        pamixer
        playerctl
        pulseaudio  # Provides pactl for PipeWire PulseAudio compatibility
    ];        

}
