-- AUTOSTART
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swaync")
    hl.exec_cmd("1password --silent")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("vicinae server")

    -- XDG Desktop Portal setup for screen sharing, file dialogs, etc.
    --
    -- Hyprland does NOT activate graphical-session.target automatically.
    -- Without the env imports below, systemd user services that depend on
    -- graphical-session.target (like xdg-desktop-portal) will fail to start
    -- with "Current graphical user session is inactive".
    --
    -- The explicit systemctl start commands are needed because xdg-desktop-portal
    -- has Requisite=graphical-session.target which blocks startup. We override
    -- that service file (in config/systemd/) to remove Requisite, but still
    -- need to manually start the services on Hyprland launch.
    --
    -- See: https://wiki.archlinux.org/title/XDG_Desktop_Portal#Portal_does_not_start
    -- See: https://wiki.hypr.land/Useful-Utilities/Systemd-start/
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal.service")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland.service")

    -- Polkit start
    -- hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)
