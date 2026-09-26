#!/usr/bin/env bash
set -euo pipefail

wallpaper_dir="${HOME}/Pictures/Wallpapers/Moonlight"
[[ -d "${wallpaper_dir}" ]] || exit 0

mapfile -d '' wallpapers < <(find "${wallpaper_dir}" -type f -print0)
((${#wallpapers[@]} > 0)) || exit 0

wallpaper="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
exec awww img "${wallpaper}" \
    --transition-type any \
    --transition-fps 144 \
    --transition-duration 1.5
