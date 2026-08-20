hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("GDK_SCALE", "2")

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

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprlock && systemctl suspend"), {
    locked = true,
})

hl.monitor({
    output = "DP-6",
    mode = "preferred",
    position = "0x-1080",
    scale = "auto",
})

hl.monitor({
    output = "DP-7",
    mode = "preferred",
    position = "1920x-1080",
    scale = "auto",
})

for workspace = 1, 9 do
    hl.workspace_rule({
        workspace = workspace,
        monitor = "eDP-1",
    })
end

for workspace = 10, 19 do
    hl.workspace_rule({
        workspace = workspace,
        monitor = "DP-6",
    })
end

for workspace = 20, 29 do
    hl.workspace_rule({
        workspace = workspace,
        monitor = "DP-7",
    })
end
