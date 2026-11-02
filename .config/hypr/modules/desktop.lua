hl.config({
    decoration = {
        shadow = {
            enabled = true,
            range = 20,
            render_power = 3,
            color = "rgb(131421)",
        },
    },
    -- hyprland-gui.lua sets vrr = 1 globally and this file loads after it.
    -- With VRR on, an output that stops receiving frames lets the refresh
    -- interval stretch past what these LG panels hold sync for, so DP-5 drops
    -- its signal whenever the cursor leaves it -- it is the rotated output, so
    -- it never gets direct scanout and has nothing else driving it.
    misc = {
        vrr = 0,
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
    hl.exec_cmd("~/.config/hypr/scripts/start_sunshine.sh")
    hl.exec_cmd("openrgb")
    -- hl.exec_cmd("openclaw gateway restart")
    hl.exec_cmd("~/.config/hypr/scripts/start_obs.sh --startreplaybuffer --minimize-to-tray")
end)

-- Monitors:
hl.monitor({
    output = "DP-4",
    mode = "2560x1440@144",
    position = "1440x0",
    scale = 1,
})
hl.monitor({
    output = "DP-5",
    mode = "2560x1440@144",
    position = "0x-415",
    scale = 1,
    transform = 1,
})
