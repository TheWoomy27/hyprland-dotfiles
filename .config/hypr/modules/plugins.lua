
hl.config { plugin = { dynamic_cursors = {

    -- enables the plugin
    enabled = true,

    -- sets the cursor behaviour, supports these values:
    -- tilt    - tilt the cursor based on x-velocity
    -- rotate  - rotate the cursor based on movement direction
    -- stretch - stretch the cursor shape based on direction and velocity
    -- none    - do not change the cursor's behaviour
    mode = "stretch",

    -- minimum angle difference in degrees after which the shape is changed
    -- smaller values are smoother, but more expensive for hw cursors
    threshold = 2,

    -- for mode = "rotate"
    rotate = {

        -- length in px of the simulated stick used to rotate the cursor
        -- most realistic if this is your actual cursor size
        length = 20,

        -- clockwise offset applied to the angle in degrees
        -- this will apply to ALL shapes
        offset = 0.0,
    },

    -- for mode = "tilt"
    tilt = {

        -- controls how powerful the tilt is, the lower, the more power
        -- this value controls at which speed (px/s) the full tilt is reached
        limit = 5000,

        -- relationship between speed and tilt, supports these values:
        -- linear             - a linear function is used
        -- quadratic          - a quadratic function is used (most realistic to actual air drag)
        -- negative_quadratic - negative version of the quadratic one, feels more aggressive
        -- see `activation` in `src/mode/utils.cpp` for how exactly the calculation is done
        activation = "negative_quadratic",

        -- time window (ms) over which the speed is calculated
        -- higher values will make slow motions smoother but more delayed
        window = 100,

        -- full tilt for each side (°)
        full = 60,
    },

    -- for mode = "stretch"
    stretch = {

        -- controls how much the cursor is stretched
        -- this value controls at which speed (px/s) the full stretch is reached
        -- the full stretch being twice the original length
        limit = 3000,

        -- relationship between speed and stretch amount, supports these values:
        -- linear             - a linear function is used
        -- quadratic          - a quadratic function is used
        -- negative_quadratic - negative version of the quadratic one, feels more aggressive
        -- see `activation` in `src/mode/utils.cpp` for how exactly the calculation is done
        activation = "negative_quadratic",

        -- time window (ms) over which the speed is calculated
        -- higher values will make slow motions smoother but more delayed
        window = 100,
    },

    -- configure shake to find
    -- magnifies the cursor if its is being shaken
    shake = {

        -- enables shake to find
        enabled = false,

        -- controls how soon a shake is detected
        -- lower values mean sooner
        threshold = 6.0,

        -- magnification level immediately after shake start
        base = 4.0,
        -- magnification increase per second when continuing to shake
        speed = 4.0,
        -- how much the speed is influenced by the current shake intensity
        influence = 0.0,

        -- maximal magnification the cursor can reach
        -- values below 1 disable the limit (e.g. 0)
        limit = 0.0,

        -- time in milliseconds the cursor will stay magnified after a shake has ended
        timeout = 2000,

        -- show cursor behaviour `tilt`, `rotate`, etc. while shaking
        effects = false,

        -- enable ipc events for shake
        -- see the `ipc` section below
        ipc = false,
    },

    -- use hyprcursor to get a higher resolution texture when the cursor is magnified
    -- see the `hyprcursor` section below
    hyprcursor = {

        -- use nearest-neighbour (pixelated) scaling when magnifying beyond texture size
        -- this will also have effect without hyprcursor support being enabled
        -- 0 - never use pixelated scaling
        -- 1 - use pixelated when no highres image
        -- 2 - always use pixelated scaling
        nearest = 1,

        -- enable dedicated hyprcursor support
        enabled = true,

        -- resolution in pixels to load the magnified shapes at
        -- be warned that loading a very high-resolution image will take a long time and might impact memory consumption
        -- -1 means we use [normal cursor size] * [shake:base option]
        resolution = -1,

        -- shape to use when clientside cursors are being magnified
        -- see the shape-name property of shape rules for possible names
        -- specifying clientside will use the actual shape, but will be pixelated
        fallback = "clientside",
    },
}}}

if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    hg.config({
        enabled = false,
        default_theme = "dark",
        default_preset = "frosted",
        -- tint_color = 0x8899aa22,

        -- -- brightness = 0.9,
        -- -- saturation = 1.0,
        -- -- vibrancy = 3.0,
        -- dark = { brightness = 0.82 },
        -- light = { adaptive_boost = 0.5 },

        layers = { enabled = 1 },
    })

    -- Layer surfaces: each call whitelists the namespace and configures it
    hg.layer("waybar", { preset = "subtle", mask_threshold = 0.05 })
    hg.layer("swaync")
    hg.layer("quickshell:bezel", { preset = "ui", mask_threshold = 0.3 })
    hg.layer("debug-panel", { exclude = true })

    -- Presets
    hg.preset("clear", {
        glass_opacity = 0.8,
        blur_strength = 1.5,
        dark = { brightness = 0.7 },
        light = { brightness = 1.2 },
    })

    hg.preset("contrasted", {
        inherits = "high_contrast",
        contrast = 1.2,
        adaptive_dim = 1.5,
        dark = { tint_color = 0x02142aa9 },
    })

    hg.preset("apple", {
        blur_strength = 2.0,
        refraction_strength = 0.12,
        chromatic_aberration = 0.018,
        fresnel_strength = 0.6,
        specular_strength = 0.5,
        -- dark = { brightness = 0.7 },
        -- light = { brightness = 1.2 },
    })

    hg.preset("apple2", {
        blur_strength = 2.2,
        blur_iterations = 3,
        refraction_strength = 0.55,
        chromatic_aberration = 0.3,
        fresnel_strength = 0.5,
        specular_strength = 0.75,
        edge_thickness = 0.05,
        lens_distortion = 0.3,
        dark = { brightness = 0.82, contrast = 0.90, saturation = 0.80, vibrancy = 0.15, adaptive_dim = 0.4 },
        light = { brightness = 1.12, contrast = 0.92, saturation = 0.85, vibrancy = 0.12, adaptive_boost = 0.4 }
    })

    hg.preset("frosted", {
        blur_strength = 2.5,
        refraction_strength = 0.0,
        chromatic_aberration = 0.0,
        fresnel_strength = 0.3,
        specular_strength = 0.2,
        dark = { brightness = 0.8 },
        light = { brightness = 1.1 },
    })

    hg.preset("subtle", {
        blur_strength = 1.0,
        refraction_strength = 0.04,
        chromatic_aberration = 0.006,
        fresnel_strength = 0.2,
        specular_strength = 0.15,
        dark = { brightness = 0.85 },
        light = { brightness = 1.15 },
    })

    hg.config({ layers = { enabled = true } })

    -- Each call whitelists the namespace and optionally configures it
    hg.layer("waybar", { preset = "subtle", mask_threshold = 0.05 })
    hg.layer("swaync")
    hg.layer("quickshell:bezel", { preset = "ui", mask_threshold = 0.3 })
    hg.layer("debug-panel", { exclude = true })
end

-- Example hyprchroma setup for a Lua config.
-- Verified against hyprland 0.56.2; see README.md for what each option does.


hl.config { plugin = { hyprchromakey = {
    enabled = true,

    similarity = 0.001,
    smoothness = 0.05,
    opacity    = 0.7,
    match      = "rgb",
    min_alpha  = 0.99,

    default_windows = "on",
    default_layers  = "off",

    force_translucent = true,

    keys = table.concat({
        "rgb(222436)",
        "rgb(1e2030)",
        "rgb(131421)",
        "rgb(2f334d)",
        "rgb(3d4054)",
        "rgb(2a2d3f)",
        -- "color rgb(181825), similarity 0.04",
        -- "profile term, color rgb(11111b), similarity 0.05, smoothness 0.03",
        -- "profile term, color rgb(1e1e2e), opacity 0.35",
    }, "; "),
}}}

-- hl.window_rule({ match = { class = "^(kitty)$" },        ["plugin:chromakey"] = "1" })
hl.window_rule({ match = { class = "^(mpv|imv)$" },      ["plugin:chromakey"] = "0" })
-- hl.layer_rule({  match = { namespace = "^(quickshell)$" },   ["plugin:chromakey"] = "1" })

-- hl.bind("SUPER + ALT + T",         hl.dsp.exec_cmd("hyprctl dispatch chromakey:toggle"))
-- hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("hyprctl dispatch chromakey:set term"))
