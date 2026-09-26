#!/usr/bin/env bash
set -euo pipefail

player="${1:-}"
title="${2:-}"
artist="${3:-}"
class_re="${player%%.*}"

[[ -n "${class_re}" ]] || exit 0

address="$(
    hyprctl clients -j 2>/dev/null |
        jq -r \
            --arg class "${class_re}" \
            --arg title "${title}" \
            --arg artist "${artist}" '
                def norm: ascii_downcase;
                [
                    .[]
                    | .score = (
                        (if ((.class // "") | norm | contains($class | norm)) then 10 else 0 end)
                        + (if (($title | length) > 0 and ((.title // "") | norm | contains($title | norm))) then 4 else 0 end)
                        + (if (($artist | length) > 0 and ((.title // "") | norm | contains($artist | norm))) then 2 else 0 end)
                    )
                    | select(.score > 0)
                ]
                | sort_by(.score)
                | reverse
                | .[0].address // empty
            '
)"

[[ -n "${address}" ]] || exit 0
exec hyprctl dispatch "hl.dsp.focus({ window = 'address:${address}' })"
