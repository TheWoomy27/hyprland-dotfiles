# Quickshell Bar Config
> CachyOS / Hyprland — JetBrains Mono Nerd Font · Gradient border style

## File Structure

```
quickshell/
├── shell.qml                  ← Entry point (pass to quickshell -c)
├── Bar.qml                    ← PanelWindow: the bar itself
├── cava-bar.ini               ← Cava config (copy to ~/.config/cava/bar.ini)
├── install.sh                 ← One-shot install script
└── modules/
    ├── BarItem.qml            ← Reusable gradient-border pill wrapper
    ├── AppLauncher.qml        ← CachyOS icon → fuzzel/rofi
    ├── Cava.qml               ← Live audio visualizer (14 bars)
    ├── SystemMonitor.qml      ← CPU % · RAM % · Temp °C
    ├── Workspaces.qml         ← Hyprland workspace switcher
    ├── Wifi.qml               ← NetworkManager SSID + signal
    ├── Audio.qml              ← PipeWire volume (scroll = adjust, click = mute)
    ├── Clock.qml              ← Live date + time
    ├── NotifButton.qml        ← swaync toggle + unread badge
    └── PowerMenu.qml          ← Lock / Logout / Reboot / Shutdown popup
```

---

## Quick Install

```bash
tar -xzf quickshell-bar.tar.gz
cd quickshell
bash install.sh
```

Then replace your Waybar line in `hyprland.conf`:
```ini
# Remove:
exec-once = waybar

# Add:
exec-once = quickshell -c ~/.config/quickshell/shell.qml
```

---

## Dependencies

| Package              | Purpose                              | Install                                |
|----------------------|--------------------------------------|----------------------------------------|
| `quickshell`         | The shell framework                  | `yay -S quickshell-git`               |
| `cava`               | Audio visualizer                     | `pacman -S cava`                       |
| `fuzzel`             | App launcher (or swap for rofi)      | `pacman -S fuzzel`                     |
| `networkmanager`     | Wifi via nmcli                       | `pacman -S networkmanager`             |
| `swaync`             | Notifications (temporary bridge)     | `pacman -S swaync`                     |
| `hyprlock`           | Screen lock                          | `pacman -S hyprlock`                   |
| `ttf-jetbrains-mono-nerd` | Font used throughout           | `pacman -S ttf-jetbrains-mono-nerd`    |
| `pipewire-pulse`     | PipeWire audio (likely installed)    | `pacman -S pipewire-pulse`             |

---

## Style Reference

| Property       | Value                                        |
|----------------|----------------------------------------------|
| Font           | JetBrains Mono Nerd Font, 12–14 px          |
| Border         | 3 px, radius 16 px (inner 13 px)            |
| Gradient       | 135° · `#7cafff` → `#3b63cf`               |
| Bar background | `#0d1117`                                   |
| Text primary   | `#cdd6f4`                                   |
| Text muted     | `#8ba3c7`                                   |
| Bar height     | 46 px (38 px content + 4 px top/bottom gap) |

---

## Module Notes

### AppLauncher
Opens **fuzzel** by default. Swap the `command` in `AppLauncher.qml` for any launcher:
```qml
command: ["rofi", "-show", "drun"]
command: ["wofi", "--show", "drun"]
```

### Cava
Quickshell **launches cava automatically** with the bundled `cava-bar.ini`.  
If you already run cava separately, set `running: false` in `Cava.qml` and configure
cava to write to its pipe yourself.

### Audio
- **Scroll** on the module → ±5% volume
- **Left-click** → toggle mute
- Values above 100% (up to 150%) are allowed and shown in amber

### Wifi
Polls `nmcli` every 10 seconds. If you prefer iwd, replace the nmcli command with:
```bash
iwctl station wlan0 show | grep 'Connected network'
```

### Workspaces
Shows workspaces 1–11 to match your screenshot.  
Change the `model: 11` in `Workspaces.qml` if you use a different count.

### NotifButton
Currently bridges to **swaync** while you migrate.  
Once you build Quickshell notifications, replace `swaync-client` calls with
`Quickshell.Services.Notifications`.

### PowerMenu
The popup uses Quickshell's `PopupWindow`. If your Quickshell build doesn't have
`PopupWindow` yet, open `PowerMenu.qml` and switch the popup to a separate
`PanelWindow` anchored `bottom: true, right: true`.

---

## Planned Modules (next step)

| Module         | Implementation hint                                          |
|----------------|--------------------------------------------------------------|
| MPRIS          | `import Quickshell.Services.Mpris` — `Mpris.players[0]`    |
| Package updates| `Process { command: ["checkupdates"] }` + count lines       |

---

## Troubleshooting

**Bar doesn't appear** — Check `journalctl --user -xe` for QML parse errors.

**Gradient Diagonal not found** — Requires Qt 6.1+. Run `qml --version` to verify.
CachyOS ships Qt 6 so this should be fine.

**Cava visualizer is flat** — Make sure audio is playing and PipeWire is set as
default. Run `cava -p ~/.config/cava/bar.ini` in a terminal first to verify.

**Workspaces don't switch** — Confirm Hyprland IPC socket is accessible:
`echo $HYPRLAND_INSTANCE_SIGNATURE`

**PipeWire volume not working** — Ensure `pipewire-pulse` is running:
`systemctl --user status pipewire-pulse`
