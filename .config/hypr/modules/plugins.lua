
hl.config { plugin = { dynamic_cursors = {

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

hl.config { plugin = { hyprchromakey = {
    enabled = true,

    similarity = 0.0,
    smoothness = 0.05,
    opacity    = 0.7,
    match      = "rgb",
    min_alpha  = 0.99,
    min_region = 1,

    default_windows = "on",
    default_layers  = "off",

    force_translucent = true,

    keys = table.concat({
        "rgb(222436)",
        "rgb(1e2030)",
        "rgb(131421)",
        "rgb(191a2a)",
        "rgb(2f334d)",
        --"rgb(3d4054)",
        --"rgb(2a2d3f)",
        -- "color rgb(181825), similarity 0.04",
        -- "profile term, color rgb(11111b), similarity 0.05, smoothness 0.03",
        -- "profile term, color rgb(1e1e2e), opacity 0.35",
    }, "; "),
}}}

hl.window_rule({ match = { class = "^(com.moonlight_stream.Moonlight)$" },        ["plugin:chromakey"] = "0" })
hl.window_rule({ match = { class = "^(mpv|imv)$" },      ["plugin:chromakey"] = "0" })
-- hl.layer_rule({  match = { namespace = "^(quickshell)$" },   ["plugin:chromakey"] = "1" })

hl.bind("SUPER + ALT + K", function() hl.plugin.hyprchromakey.toggle() end)

if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    hg.preset("hyaline-window", {
        -- Window material values
    })

    hg.preset("hyaline-chrome", {
        -- Hyaline’s custom bar contour/refraction values
    })

    hg.config({
        enabled = true,
        manage_window_blur = true,
        default_theme = "dark",
        default_preset = "hyaline-window",
        layers = { enabled = true },
    })

    hg.layer("hyaline:field", { exclude = true })
    hg.layer("hyaline:corners", { exclude = true })
    hg.layer("hyaline:bar", {
        preset = "hyaline-chrome",
        mask_threshold = 0.004,
    })
end