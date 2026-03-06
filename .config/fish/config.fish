source /usr/share/cachyos-fish-config/cachyos-config.fish
source ~/.config/fish/desktop.fish
source ~/.config/fish/laptop.fish

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias cmatrix='cmatrix -C blue'
set -gx NEWT_COLORS "root=#c8d3f5,#222436;border=#131421,#1e2030;window=#c8d3f5,#1e2030;shadow=#222436,#222436;title=#c8d3f5,#222436;button=#c8d3f5,#1e2030;actbutton=#c8d3f5,#444a73;checkbox=black,#c8d3f5;actcheckbox=#c8d3f5,#444a73;entry=#c8d3f5,#1e2030;label=#c8d3f5,#1e2030;listbox=#c8d3f5,#1e2030;actlistbox=#7cafff,#1e2030;textbox=#c8d3f5,#1e2030;acttextbox=#c8d3f5, #131421;helpline=#131421,#1e2030;roottext=#131421,#1e2030;emptyscale=red,#c8d3f5;fullscale=green,#c8d3f5;disabled_entry=gray,#c8d3f5;compactbutton=#c8d3f5,#131421;actsellistbox=#d5def8,#444a73;sellistbox=black,#444a73'   nmtui"
alias vencord='kill $(pidof discord) && sh -c "$(curl -sS https://vencord.dev/install.sh)" && discord & disown'
  
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"

set -gx PATH $PATH ~/.npm-global/bin   
set -gx OPENCLAW_WS_DELTA_THROTTLE_MS 20


# OpenClaw Completion
# source "/home/austin/.openclaw/completions/openclaw.fish"
