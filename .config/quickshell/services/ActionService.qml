pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property string scriptDir: Quickshell.shellDir + "/scripts"

    function run(command) {
        if (command && command.length > 0)
            Quickshell.execDetached(command)
    }

    function hyprDispatch(expression) {
        run(["hyprctl", "dispatch", expression])
    }

    function launchVicinae() { run(["vicinae", "toggle"]) }
    function launchWofi() { run(["wofi", "--show", "drun"]) }
    function openPavucontrol() { run(["pavucontrol"]) }
    function openWaypaper() { run(["waypaper"]) }
    function openPowerMenu() { run(["wlogout"]) }
    function lockSession() { run(["hyprlock"]) }
    function randomWallpaper() { run([scriptDir + "/random-wallpaper.sh"]) }

    function openBtop() {
        hyprDispatch("hl.dsp.exec_cmd(\"[float on; size 1150 646;] kitty -e btop\")")
    }

    function openCava() {
        hyprDispatch("hl.dsp.exec_cmd(\"[float on; size 1150 646;] kitty -e cava\")")
    }

    function openNetworkTui() {
        hyprDispatch("hl.dsp.exec_cmd(\"[float; size 1150 646;] kitty -e "
                     + scriptDir + "/network-tui.sh\")")
    }

    function openHyprmod() {
        hyprDispatch("hl.dsp.exec_cmd(\"[workspace special:magic silent] kitty --class hyprmod hyprmod\")")
    }

    function focusWorkspace(workspaceId) {
        var id = Math.trunc(Number(workspaceId))
        if (isNaN(id) || id < 1)
            return
        hyprDispatch("hl.dsp.focus({ workspace = " + id + " })")
    }

    function focusMediaSource(player, title, artist) {
        run([scriptDir + "/focus-media-source.sh", player || "", title || "", artist || ""])
    }
}
