hl.config({
    general = {
        col = {
            active_border = {
                colors = {"rgba(3b63cfff)", "rgba(7cafffff)"},
                angle = 225,
            },
            inactive_border = "rgba(5A617Daa)",
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 20,
        rounding_power = 3,
        active_opacity = 0.85,
        inactive_opacity = 0.85,
        shadow = {
            enabled = false,
            range = 10,
            render_power = 2,
            color = "rgba(1a1a1a7e)",
        },
        blur = {
            enabled = true,
            size = 5,
            passes = 2,
            ignore_opacity = true,
            noise = 0.04,
            xray = false,
            contrast = 1.5,
            brightness = 0.9,
            vibrancy = 1,
            new_optimizations = true,
        },
    },
    animations = {
        enabled = true,
    },
})

-- Bezier curves
hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("smoothOut", { type = "bezier", points = { {0.36, 0}, {0.66, -0.56} } })
hl.curve("smoothIn", { type = "bezier", points = { {0.25, 1}, {0.5, 1} } })
hl.curve("overshot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("softSnap", { type = "bezier", points = { {0.4, 0}, {0.2, 1} } })
hl.curve("fluent", { type = "bezier", points = { {0.0, 0.0}, {0.2, 1.0} } })
hl.curve("specialWorkSwitch", { type = "bezier", points = { {0.05, 0.7}, {0.1, 1} } })
hl.curve("emphasizedAccel", { type = "bezier", points = { {0.3, 0}, {0.8, 0.15} } })
hl.curve("emphasizedDecel", { type = "bezier", points = { {0.05, 0.7}, {0.1, 1} } })
hl.curve("standard", { type = "bezier", points = { {0.2, 0}, {0, 1} } })

-- Windows
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 5,
    bezier = "overshot",
    style = "popin 80%",
})
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 4,
    bezier = "overshot",
    style = "popin 80%",
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 3,
    bezier = "smoothOut",
    style = "popin 95%",
})
hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 4,
    bezier = "softSnap",
})

-- Layers
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4,
    bezier = "smoothIn",
    style = "popin 50%",
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 3,
    bezier = "softSnap",
    style = "popin 80%",
})

-- Fade
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 4,
    bezier = "smoothIn",
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 4,
    bezier = "smoothIn",
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 1.5,
    bezier = "smoothOut",
})
hl.animation({
    leaf = "fadeSwitch",
    enabled = true,
    speed = 4,
    bezier = "smoothIn",
})
hl.animation({
    leaf = "fadeShadow",
    enabled = true,
    speed = 4,
    bezier = "smoothIn",
})
hl.animation({
    leaf = "fadeDim",
    enabled = true,
    speed = 4,
    bezier = "smoothIn",
})
hl.animation({
    leaf = "fadeDpms",
    enabled = true,
    speed = 4,
    bezier = "smoothIn",
})
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 5,
    bezier = "overshot",
    style = "slidefade 30%",
})
hl.animation({
    leaf = "specialWorkspace",
    enabled = true,
    speed = 5,
    bezier = "overshot",
    style = "slidefadevert 30%",
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 2,
    bezier = "linear",
})
hl.animation({
    leaf = "borderangle",
    enabled = true,
    speed = 6,
    bezier = "emphasizedDecel",
})
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 5,
    bezier = "emphasizedDecel",
    style = "slide",
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 4,
    bezier = "emphasizedAccel",
    style = "slide",
})
hl.animation({
    leaf = "fadeLayers",
    enabled = true,
    speed = 5,
    bezier = "standard",
})
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 5,
    bezier = "emphasizedDecel",
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 3,
    bezier = "emphasizedAccel",
})
hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 6,
    bezier = "standard",
})
hl.animation({
    leaf = "specialWorkspace",
    enabled = true,
    speed = 4,
    bezier = "specialWorkSwitch",
    style = "slidefadevert 15%",
})
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 6,
    bezier = "standard",
})
hl.animation({
    leaf = "fadeDim",
    enabled = true,
    speed = 6,
    bezier = "standard",
})

hl.config({
    dwindle = {
        preserve_split = false,
        force_split = 0,
        smart_split = false,
        split_bias = 1,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = false,
        allow_session_lock_restore = true,
        initial_workspace_tracking = 0
    },
})