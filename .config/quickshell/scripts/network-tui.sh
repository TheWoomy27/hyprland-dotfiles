#!/usr/bin/env bash
set -euo pipefail

export NEWT_COLORS='root=#c8d3f5,#222436;border=#131421,#1e2030;window=#c8d3f5,#1e2030;shadow=#222436,#222436;title=#c8d3f5,#222436;button=#c8d3f5,#1e2030;actbutton=#c8d3f5,#444a73;checkbox=black,#c8d3f5;actcheckbox=#c8d3f5,#444a73;entry=#c8d3f5,#1e2030;label=#c8d3f5,#1e2030;listbox=#c8d3f5,#1e2030;actlistbox=#7cafff,#1e2030;textbox=#c8d3f5,#1e2030;acttextbox=#c8d3f5,#131421;helpline=#131421,#1e2030;roottext=#131421,#1e2030;emptyscale=red,#c8d3f5;fullscale=green,#c8d3f5;disabled_entry=gray,#c8d3f5;compactbutton=#c8d3f5,#131421;actsellistbox=#d5def8,#444a73;sellistbox=black,#444a73'
exec nmtui
