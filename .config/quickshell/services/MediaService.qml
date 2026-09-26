pragma Singleton

import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var active: players.find(player => player.isPlaying)
        || players[0]
        || null
    readonly property bool available: active !== null

    function shortName(player) {
        if (!player)
            return ""

        const prefix = "org.mpris.MediaPlayer2."
        const name = player.dbusName || player.identity || ""
        return name.startsWith(prefix) ? name.slice(prefix.length) : name
    }

    function toggle(player) {
        const target = player || active
        if (target && target.canTogglePlaying)
            target.togglePlaying()
    }

    function previous(player) {
        const target = player || active
        if (target && target.canGoPrevious)
            target.previous()
    }

    function next(player) {
        const target = player || active
        if (target && target.canGoNext)
            target.next()
    }

    function stop(player) {
        const target = player || active
        if (target && target.canControl)
            target.stop()
    }

    function toggleShuffle(player) {
        const target = player || active
        if (target && target.shuffleSupported)
            target.shuffle = !target.shuffle
    }

    function seekTo(player, seconds) {
        if (player && player.canSeek && player.positionSupported)
            player.position = Math.max(0, Math.min(player.length, seconds))
    }
}
