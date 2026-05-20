#!/usr/bin/env bash
[[ $HYDE_SHELL_INIT -ne 1 ]] && eval "$(hyde-shell init)"

selected_wall="${1:-${XDG_CACHE_HOME:-$HOME/.cache}/hyde/wall.set}"
[ -z "$selected_wall" ] && echo "No input wallpaper" && exit 1
selected_wall="$(readlink -f "$selected_wall")"

is_video=$(file --mime-type -b "$selected_wall" | grep -c '^video/')
if [ "$is_video" -eq 1 ]; then
    print_log -sec "wallpaper" -stat "converting video" "$selected_wall"
    mkdir -p "$HYDE_CACHE_HOME/wallpapers/thumbnails"
    cached_thumb="$HYDE_CACHE_HOME/wallpapers/$(${hashMech:-sha1sum} "$selected_wall" | cut -d' ' -f1).png"
    extract_thumbnail "$selected_wall" "$cached_thumb"
    selected_wall="${cached_thumb}"
fi

# Write config in hyprpaper v0.8.x format (wallpaper { } blocks)
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprpaper.conf"
mkdir -p "$(dirname "$CONFIG_FILE")"

cat <<EOF >"$CONFIG_FILE"
wallpaper {
    monitor =
    path = ${selected_wall}
    fit_mode = cover
}
EOF

# Restart hyprpaper to pick up new config
if systemctl --user is-active --quiet hyprpaper.service 2>/dev/null; then
    systemctl --user restart hyprpaper.service
elif pgrep hyprpaper >/dev/null 2>&1; then
    killall hyprpaper 2>/dev/null
    sleep 0.5
    setsid hyprpaper --config "$CONFIG_FILE" &
else
    setsid hyprpaper --config "$CONFIG_FILE" &
fi
