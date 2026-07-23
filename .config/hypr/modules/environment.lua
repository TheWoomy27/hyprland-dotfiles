hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GDM_BACKEND", "nvidia-drm")
hl.env("renderer", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("XCURSOR_SIZE", "24")
hl.env("AQ_NO_MODESET_COMMIT", "1")
hl.env("WLR_DRM_NO_ATOMIC", "1")
hl.env("WB_FORCE_SYSTEM_COLORS", "1")
hl.env("HYPRCURSOR_THEME", "Adwaita-Moonlight")
hl.env("HYPRCURSOR_SIZE", "28")
hl.env("GTK_THEME", "catppuccin-moonlight")
hl.env("GDK_BACKEND", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "0")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_STYLE_OVERRIDE", "Fusion")
