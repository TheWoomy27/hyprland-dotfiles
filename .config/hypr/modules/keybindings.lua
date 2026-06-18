local var_mainMod = "SUPER"

-- ##################

-- ## KEYBINDINGS ###

-- ##################
require("modules.variables")

-- https://wiki.hypr.land/Configuring/Keywords/

-- https://wiki.hypr.land/Configuring/Binds/ for more
-- hl.bind("power-button", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind(var_mainMod .. " + C", hl.dsp.window.close())
hl.bind(var_mainMod .. " + SHIFT + ESCAPE", hl.dsp.exit())
hl.bind(var_mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(var_mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(var_mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(var_preserveSplitOn))
hl.bind(var_mainMod .. " + ALT + P", hl.dsp.exec_cmd(var_preserveSplitOff))
hl.bind(var_mainMod .. " + S", hl.dsp.layout("togglesplit"))
hl.bind(var_mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("grim -g \"$(slurp)\" /tmp/ocr_screenshot.png && tesseract /tmp/ocr_screenshot.png stdout | wl-copy && rm /tmp/ocr_screenshot.png"))
hl.bind(var_mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(var_mainMod .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind(var_mainMod .. " + SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(var_mainMod .. " + ESCAPE", hl.dsp.exec_cmd("pidof " .. var_logoutMenu .. " || " .. var_logoutMenu))
hl.bind(var_mainMod .. " + L", hl.dsp.exec_cmd("hyprlock --grace 5"))
hl.bind(var_mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("pidof hyprpicker || hyprpicker --autocopy"))
hl.bind(var_mainMod .. " + SPACE", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind(var_mainMod .. " + O", hl.dsp.window.set_prop({ prop = "opaque", value = "toggle", window = "active" }))
hl.bind(var_mainMod .. " + N", hl.dsp.exec_cmd("~/.config/swaync/scripts/open_swaync.sh"))
hl.bind(var_mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("~/.config/swaync/scripts/launch.sh"))
hl.bind(var_mainMod .. " + SHIFT + CTRL + N", hl.dsp.exec_cmd("swaync-client --reload-config && swaync-client --reload-css"))
hl.bind(var_mainMod .. " + K", hl.dsp.exec_cmd("hyprctl kill"))
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd("/home/austin/Projects/promptrecover/target/release/promptrecover last --paste"))
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("/home/austin/Projects/promptrecover/target/release/promptrecover menu"))

-- Launch apps
hl.bind(var_mainMod .. " + Q", hl.dsp.exec_cmd(var_smartSplitOn .. " && " .. var_terminal .. " && " .. var_smartSplitOff))
hl.bind(var_mainMod .. " + ALT + Q", hl.dsp.exec_cmd("[float on; size 1150 646;] " .. var_terminal))
hl.bind(var_mainMod .. " + B", hl.dsp.exec_cmd(var_smartSplitOn .. " && " .. var_browser .. " && " .. var_smartSplitOff))
hl.bind(var_mainMod .. " + ALT + B", hl.dsp.exec_cmd("[float on; size 1150 646;] " .. var_browser))
hl.bind(var_mainMod .. " + E", hl.dsp.exec_cmd(var_smartSplitOn .. " && " .. var_fileManager .. " && " .. var_smartSplitOff))
hl.bind(var_mainMod .. " + T", hl.dsp.exec_cmd(var_smartSplitOn .. " && " .. var_textEditor .. " && " .. var_smartSplitOff))
hl.bind(var_mainMod .. " + V", hl.dsp.exec_cmd(var_smartSplitOn .. " && " .. var_codeEditor .. " && " .. var_smartSplitOff))
hl.bind(var_mainMod .. " + H", hl.dsp.exec_cmd(var_smartSplitOn .. " && " .. var_codeEditor .. " /home/austin/.vscode/hypr.code-workspace && " .. var_smartSplitOff))
hl.bind("SHIFT + CTRL + ESCAPE", hl.dsp.exec_cmd(var_smartSplitOn .. " && kitty btop && " .. var_smartSplitOff))
hl.bind(var_mainMod .. " + R", hl.dsp.exec_cmd("pidof " .. var_menu .. " || " .. var_menu))
hl.bind(var_mainMod .. " + W", hl.dsp.exec_cmd("pidof waypaper || waypaper"))

-- Kill and reload apps
hl.bind(var_mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/.config/waybar/scripts/launch.sh"))
hl.bind(var_mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("~/.config/quickshell/scripts/launch.sh"))
hl.bind(var_mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("killall -9 openrgb && openrgb"))
hl.bind(var_mainMod .. " + equal", hl.dsp.exec_cmd("hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1')"))
hl.bind(var_mainMod .. " + minus", hl.dsp.exec_cmd("hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.9) | if . < 1 then 1 else . end')"))

-- Move focus with mainMod + arrow keys
hl.bind(var_mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(var_mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(var_mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(var_mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(var_mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(var_mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(var_mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(var_mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
hl.bind("F11", hl.dsp.window.fullscreen())

-- Switch workspaces with mainMod + [0-9]
hl.bind(var_mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(var_mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(var_mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(var_mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(var_mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(var_mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(var_mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(var_mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(var_mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(var_mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(var_mainMod .. " + CTRL + 1", hl.dsp.focus({ workspace = 11 }))
hl.bind(var_mainMod .. " + CTRL + 2", hl.dsp.focus({ workspace = 12 }))
hl.bind(var_mainMod .. " + CTRL + 3", hl.dsp.focus({ workspace = 13 }))
hl.bind(var_mainMod .. " + CTRL + 4", hl.dsp.focus({ workspace = 14 }))
hl.bind(var_mainMod .. " + CTRL + 5", hl.dsp.focus({ workspace = 15 }))
hl.bind(var_mainMod .. " + CTRL + 6", hl.dsp.focus({ workspace = 16 }))
hl.bind(var_mainMod .. " + CTRL + 7", hl.dsp.focus({ workspace = 17 }))
hl.bind(var_mainMod .. " + CTRL + 8", hl.dsp.focus({ workspace = 18 }))
hl.bind(var_mainMod .. " + CTRL + 9", hl.dsp.focus({ workspace = 19 }))
hl.bind(var_mainMod .. " + CTRL + 0", hl.dsp.focus({ workspace = 20 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(var_mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(var_mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(var_mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(var_mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(var_mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(var_mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(var_mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(var_mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(var_mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(var_mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + 1", hl.dsp.window.move({ workspace = 11 }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + 2", hl.dsp.window.move({ workspace = 12 }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + 3", hl.dsp.window.move({ workspace = 13 }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + 4", hl.dsp.window.move({ workspace = 14 }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + 5", hl.dsp.window.move({ workspace = 15 }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + 6", hl.dsp.window.move({ workspace = 16 }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + 7", hl.dsp.window.move({ workspace = 17 }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + 8", hl.dsp.window.move({ workspace = 18 }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + 9", hl.dsp.window.move({ workspace = 19 }))
hl.bind(var_mainMod .. " + CTRL + SHIFT + 0", hl.dsp.window.move({ workspace = 20 }))

-- Special workspaces (scratchpad)
hl.bind(var_mainMod .. " + Z", hl.dsp.workspace.toggle_special("magic"))
hl.bind(var_mainMod .. " + SHIFT + Z", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(var_mainMod .. " + ALT + Z", hl.dsp.workspace.toggle_special("minimized"))
hl.bind(var_mainMod .. " + SHIFT + ALT + Z", hl.dsp.window.move({ workspace = "special:minimized" }))

-- Scroll through existing workspaces with mainMod + scroll/bracket
hl.bind(var_mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(var_mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(var_mainMod .. " + bracketleft", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(var_mainMod .. " + bracketright", hl.dsp.focus({ workspace = "e+1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(var_mainMod .. " + mouse:272", hl.dsp.window.drag(), {
    mouse = true,
})
hl.bind(var_mainMod .. " + mouse:273", hl.dsp.window.resize(), {
    mouse = true,
})

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), {
    repeating = true,
    locked = true,
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
    repeating = true,
    locked = true,
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
    repeating = true,
    locked = true,
})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {
    repeating = true,
    locked = true,
})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), {
    repeating = true,
    locked = true,
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), {
    repeating = true,
    locked = true,
})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {
    locked = true,
})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true,
})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true,
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {
    locked = true,
})

hl.bind("ALT + S", hl.dsp.pass({ window = "class:^(com\\.obsproject\\.Studio)$" }))
