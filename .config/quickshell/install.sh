#!/usr/bin/env bash
# install.sh — Deploy the Quickshell bar config
# Run from the extracted directory.

set -e

QS_DIR="$HOME/.config/quickshell"
CAVA_DIR="$HOME/.config/cava"

echo "==> Installing Quickshell bar config to $QS_DIR"

# Back up existing config if present
if [ -d "$QS_DIR" ]; then
    BACKUP="$QS_DIR.bak.$(date +%Y%m%d_%H%M%S)"
    echo "    Backing up existing config to $BACKUP"
    mv "$QS_DIR" "$BACKUP"
fi

# Copy files
mkdir -p "$QS_DIR/modules"
cp shell.qml   "$QS_DIR/"
cp Bar.qml     "$QS_DIR/"
cp modules/*.qml "$QS_DIR/modules/"

# Cava config
mkdir -p "$CAVA_DIR"
if [ ! -f "$CAVA_DIR/bar.ini" ]; then
    cp cava-bar.ini "$CAVA_DIR/bar.ini"
    echo "    Installed cava config → $CAVA_DIR/bar.ini"
else
    echo "    Cava config already exists at $CAVA_DIR/bar.ini — skipping"
fi

# ── Dependency check ──────────────────────────────────────────────────────
echo ""
echo "==> Checking dependencies..."
MISSING=()

check() {
    command -v "$1" &>/dev/null || MISSING+=("$1")
}

check quickshell
check cava
check fuzzel
check nmcli
check swaync-client
check hyprlock

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "    ⚠  Missing commands (install with pacman/yay):"
    for cmd in "${MISSING[@]}"; do
        echo "       - $cmd"
    done
    echo ""
    echo "    pacman -S quickshell cava fuzzel networkmanager swaync hyprlock"
else
    echo "    ✓ All dependencies found"
fi

echo ""
echo "==> Done! Launch with:"
echo "    quickshell -c $QS_DIR/shell.qml"
echo ""
echo "    Or add to your Hyprland config:"
echo "    exec-once = quickshell -c $QS_DIR/shell.qml"
echo ""
echo "NOTE: Remove or comment out your Waybar exec-once line first."
