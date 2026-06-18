hl.window_rule({
    match = {
        class = "^(mpc-qt)$",
        title = "^(Media Player Classic Qute Theater)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        class = "^(waypaper)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        class = "^(org.pulseaudio.pavucontrol)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        class = "^(xdg-desktop-portal-gtk)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        title = "^(Choose Files)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        title = "^(Open Folder|Open File|.* wants to open|Select one or more files|Select files|Add files...)$",
    },
    float = true,
    size = {"monitor_w * 0.449", "monitor_h * 0.449"},
    move = {"monitor_w * 0.2755", "((monitor_h / 3.4) )"},
})
hl.window_rule({
    match = {
        title = "^(Bluetooth Devices)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        title = "^(Open Folder)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        title = "^(\"Sign in - Google Accounts - Brave\")$",
    },
    float = true,
})
hl.window_rule({
    match = {
        title = "^(Friends List)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        title = "^(wleave)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        title = "^(Media viewer)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        title = "^(Welcome to Xbox)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        class = "^(org.pulseaudio.pavucontrol)$",
    },
    size = "800 600",
})
hl.window_rule({
    match = {
        class = "^(brave-browser)$",
    },
    focus_on_activate = true,
})
hl.window_rule({
    match = {
        class = "^(nautilus)$",
    },
    focus_on_activate = true,
})
hl.window_rule({
    match = {
        title = "^(Minecraft)$",
    },
    opacity = 1.0,
})
hl.window_rule({
    match = {
        class = "^(io.github.bluemancz.hyprmod)$",
    },
    float = true,
})
hl.window_rule({
    match = {
        class = ".*",
    },
    suppress_event = "maximize",
})
hl.window_rule({
    match = {
        class = "^$",
        title = "^$",
        xwayland = 1,
        float = 1,
        fullscreen = 0,
        pin = 0,
    },
    no_focus = true,
})
hl.layer_rule({
    match = {
        namespace = "swaync-control-center",
    },
    animation = "slide right",
})
hl.layer_rule({
    match = {
        namespace = "logout_dialog",
    },
    animation = "popin 90%",
})
hl.layer_rule({
    match = {
        namespace = "wofi",
    },
    animation = "popin 0%",
})
hl.layer_rule({
    match = {
        namespace = "hyprpaper",
    },
    animation = "false",
})
hl.layer_rule({
    match = {
        namespace = "vicinae",
    },
    blur = true,
})
hl.layer_rule({
    match = {
        namespace = "waybar",
    },
    animation = "slide up",
})
hl.layer_rule({
    match = {
        namespace = "quickshell",
    },
    animation = "slide up",
})
hl.layer_rule({
    match = {
        namespace = "hyprpicker",
    },
    animation = "none",
})
hl.layer_rule({
    match = {
        namespace = "selection",
    },
    animation = "fade",
})
hl.workspace_rule({
    workspace = 1,
    monitor = "DP-4",
})
hl.workspace_rule({
    workspace = 2,
    monitor = "DP-4",
})
hl.workspace_rule({
    workspace = 3,
    monitor = "DP-4",
})
hl.workspace_rule({
    workspace = 4,
    monitor = "DP-4",
})
hl.workspace_rule({
    workspace = 5,
    monitor = "DP-4",
})
hl.workspace_rule({
    workspace = 6,
    monitor = "DP-4",
})
hl.workspace_rule({
    workspace = 7,
    monitor = "DP-4",
})
hl.workspace_rule({
    workspace = 8,
    monitor = "DP-4",
})
hl.workspace_rule({
    workspace = 9,
    monitor = "DP-4",
})
hl.workspace_rule({
    workspace = 10,
    monitor = "DP-5",
})
hl.workspace_rule({
    workspace = 11,
    monitor = "DP-5",
})
hl.workspace_rule({
    workspace = 12,
    monitor = "DP-5",
})
hl.workspace_rule({
    workspace = 13,
    monitor = "DP-5",
})
hl.workspace_rule({
    workspace = 14,
    monitor = "DP-5",
})
hl.workspace_rule({
    workspace = 15,
    monitor = "DP-5",
})
hl.workspace_rule({
    workspace = 16,
    monitor = "DP-5",
})
hl.workspace_rule({
    workspace = 17,
    monitor = "DP-5",
})
hl.workspace_rule({
    workspace = 18,
    monitor = "DP-5",
})
hl.workspace_rule({
    workspace = 19,
    monitor = "DP-5",
})
