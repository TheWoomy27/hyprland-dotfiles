hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("GDK_SCALE", "2")
hl.env("AQ_DRM_DEVICES", "/dev/dri/intel-igpu")

hl.window_rule({
    match = {
        class = "^(discord)$",
    },
    workspace = 4,
})

hl.window_rule({
    match = {
        class = "^(org.telegram.desktop)$",
    },
    workspace = 4,
})

-- hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprlock && systemctl suspend"), {
--     locked = true,
-- })

hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "0x0",
    scale = "auto",
    bitdepth = 10
})

hl.monitor({
    output = "DP-7",
    mode = "preferred",
    position = "0x-1080",
    scale = "auto",
})

hl.monitor({
    output = "DP-8",
    mode = "preferred",
    position = "1920x-1080",
    scale = "auto",
})

hl.monitor({
    output = "DP-4",
    mode = "preferred",
    position = "-1440x-1850",
    transform = 1,
    scale = "auto",
})

hl.monitor({
    output = "HDMI-A-2",
    mode = "preferred",
    position = "0x-1440",
    scale = "auto",
})

for workspace = 1, 10 do
    hl.workspace_rule({
        workspace = workspace,
        monitor = "eDP-1",
    })
end

for workspace = 11, 19 do
    hl.workspace_rule({
        workspace = workspace,
        monitor = "DP-4",
    })
end

for workspace = 21, 29 do
    hl.workspace_rule({
        workspace = workspace,
        monitor = "HDMI-A-2",
    })
end
