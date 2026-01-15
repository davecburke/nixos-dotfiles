{ config, pkgs, ... }:

{
    # ReGreet (GTK greeter) + theming knobs
    programs.regreet = {
        enable = true;
        # env = {
        #     # Helpful for wayland apps sometimes
        #     XDG_CURRENT_DESKTOP = "niri";
        #     XDG_SESSION_DESKTOP = "niri";
        # };
    };

    # Set up regreet config file
    environment.etc."greetd/regreet.toml" = {
        source = ./../themes/regreet/config.toml;
        mode = "0644";
    };

    # greetd: run ReGreet as greeter, then start niri when you log in
    services.greetd = {
        enable = true;

        settings = {
        default_session = {
            # run regreet in cage
            command = "${pkgs.cage}/bin/cage -s -- ${config.programs.regreet.package}/bin/regreet";
            user = "greeter";
        };

        # optional: auto-login / initial session (remove if you don’t want it)
        # initial_session = {
        #   command = "${pkgs.niri}/bin/niri-session";
        #   user = "dave";
        # };
        };
    };

    # Make sure the greeter user can use the GPU/input
    users.users.greeter.extraGroups = [ "video" "input" ];
}