require("modules.aesthetics")
require("modules.autostart")
require("modules.environment")
require("modules.input-rules")
require("modules.keybindings")
require("modules.permissions")
require("modules.plugins")
require("modules.window-rules")
require("hyprland-gui")

-- Load laptop-specific settings only on systems with an internal eDP-1 panel.
local connector_check = io.popen(
    'for connector in /sys/class/drm/card*-eDP-1; do '
        .. '[ -e "$connector" ] && printf yes && break; '
    .. 'done'
)
local has_internal_panel = connector_check and connector_check:read("*a") == "yes"
if connector_check then
    connector_check:close()
end

if has_internal_panel then
    require("modules.laptop")
else
    require("modules.desktop")
end

dofile(os.getenv('HOME') .. '/Projects/liquid-glass-shell/hypr/glass.lua')

if has_internal_panel then
    require("modules.laptop-performance")
end

-- >>> MacShell (added by install.sh) >>>
-- Load the generated MacShell autostart and keybind module.
require("macshell")
-- Liquid Glass: blur behind the shell surfaces
hl.layer_rule({ name = "macdock",  match = { namespace = "macdock"  }, blur = true, ignore_alpha = 0.2,  no_anim = true })
hl.layer_rule({ name = "macspot",  match = { namespace = "macspot"  }, blur = true, ignore_alpha = 0.05, no_anim = true })
hl.layer_rule({ name = "macbarbg", match = { namespace = "macbarbg" }, blur = true, ignore_alpha = 0.05, no_anim = true })
hl.layer_rule({ name = "macshot",  match = { namespace = "macshot"  }, no_anim = true })
-- <<< MacShell <<<
