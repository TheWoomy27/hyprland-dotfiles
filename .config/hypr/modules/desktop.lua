hl.config({
    decoration = {
        shadow = {
            enabled = true,
            range = 15,
            render_power = 3,
            color = "rgb(131421)",
        },
    },
})

hl.window_rule({
    match = {
        class = "^(vesktop)$",
    },
    workspace = 11,
})
hl.window_rule({
    match = {
        class = "^(org.telegram.desktop)$",
    },
    workspace = 11,
})
hl.window_rule({
    match = {
        class = "^(openrgb)$",
    },
    workspace = 12,
})
hl.window_rule({
    match = {
        class = "^(org.openrgb.OpenRGB)$",
    },
    workspace = 12,
})

hl.window_rule({
    match = {
        class = "^(com.obsproject.Studio)$",
    },
    workspace = "special:minimized silent",
})

hl.on("hyprland.start", function()
    hl.exec_cmd("sunshine")
    hl.exec_cmd("openrgb")
    hl.exec_cmd("openclaw gateway restart")
    hl.exec_cmd("~/.config/hypr/scripts/start_obs.sh --startreplaybuffer --minimize-to-tray")
end)

