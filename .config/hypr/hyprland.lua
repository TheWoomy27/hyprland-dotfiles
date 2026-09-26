require("modules.aesthetics")
require("modules.autostart")
require("modules.desktop")
require("modules.environment")
require("modules.input-rules")
require("modules.keybindings")
require("modules.monitors")
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

dofile(os.getenv('HOME') .. '/Projects/Liquid Glass Shell/Output/hypr/glass.lua')
