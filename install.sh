#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------
# hyprland-kali-linux -- install script
# adapts HyDE (Hyprland Desktop Environment) for Kali Linux
# original HyDE project: https://github.com/HyDE-Project/HyDE
# -----------------------------------------------------

cat << 'BANNER'

    ------------------------------------------
     _                      _   _             _
    | |__  _   _ _ __  _ __| | | | __ _ _ __ | |
    | '_ \| | | | '_ \| '__| | | |/ _` | '_ \| |
    | | | | |_| | |_) | |  | |_| | (_| | | | | |
    |_| |_|\__, | .__/|_|   \___/ \__,_|_| |_|_|
           |___/|_|

      kali linux adaptation of hyde project
    ------------------------------------------

BANNER

# -----------------------------------------------------
# configuration
# -----------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIGS_DIR="${SCRIPT_DIR}/configs"
BACKUP_DIR="$HOME/configs-backup-$(date +%Y%m%d-%H%M%S)"

# -----------------------------------------------------
# helper functions
# -----------------------------------------------------
print_step() { echo ">>> $1"; }
print_ok()   { echo "  [OK] $1"; }
print_warn() { echo "  [WARN] $1"; }

check_root() {
    if [ "$(id -u)" -eq 0 ]; then
        echo "do not run this script as root. use a normal user with sudo."
        exit 1
    fi
}

check_configs() {
    if [ ! -d "${CONFIGS_DIR}/.config" ] || [ ! -d "${CONFIGS_DIR}/.local" ]; then
        echo "error: configs directory is missing or incomplete."
        echo "expected: ${CONFIGS_DIR}/.config and ${CONFIGS_DIR}/.local"
        echo "make sure you cloned the full repository."
        exit 1
    fi
}

# -----------------------------------------------------
# step 0: pre-flight checks
# -----------------------------------------------------
print_step "checking prerequisites..."

check_root
check_configs

# verify we are on kali / debian-based
if ! grep -qi "kali\|debian" /etc/os-release 2>/dev/null; then
    print_warn "this script is designed for kali linux / debian. your system may not be compatible."
    read -rp "continue anyway? (y/N): " yn
    [ "${yn,,}" != "y" ] && exit 0
fi

print_ok "system is compatible"
print_ok "configs found at ${CONFIGS_DIR}"

# -----------------------------------------------------
# step 1: install core hyprland packages
# -----------------------------------------------------
print_step "updating package lists..."
sudo apt update

print_step "installing hyprland and gui utilities..."
sudo apt install -y hyprland hyprland-guiutils
print_ok "hyprland base installed"

# -----------------------------------------------------
# step 2: install hyde dependencies
# -----------------------------------------------------
print_step "installing hyde dependencies (this may take a while)..."

# --- bars, launchers, notifications ---
sudo apt install -y \
    waybar \
    dunst \
    rofi \
    wlogout \
    || print_warn "some ui packages failed to install"

# --- hyprland ecosystem ---
sudo apt install -y \
    hypridle \
    hyprlock \
    hyprsunset \
    hyprpicker \
    hyprpaper \
    hyprpolkitagent \
    grim \
    slurp \
    cliphist \
    || print_warn "some hyprland ecosystem packages failed to install"

# --- system services and applets ---
sudo apt install -y \
    udiskie \
    blueman \
    network-manager-gnome \
    xdg-desktop-portal-hyprland \
    || print_warn "some system service packages failed to install"

# --- theming (gtk / qt) ---
sudo apt install -y \
    nwg-look \
    qt5ct \
    qt6ct \
    qt-style-kvantum \
    qt-style-kvantum-themes \
    || print_warn "some theming packages failed to install"

# --- utilities ---
sudo apt install -y \
    kitty \
    fastfetch \
    starship \
    fzf \
    jq \
    imagemagick \
    parallel \
    fonts-noto-color-emoji \
    uwsm \
    || print_warn "some utility packages failed to install"

print_ok "all installable dependencies processed"

# -----------------------------------------------------
# step 2b: install uv (python package manager required by hyde)
# -----------------------------------------------------
print_step "installing uv package manager..."
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null || print_warn "uv install failed; some hyde features may not work"
    # add uv to PATH for this session
    [ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env" 2>/dev/null || true
    print_ok "uv installed"
else
    print_ok "uv already installed"
fi

# -----------------------------------------------------
# step 2c: install nerd fonts (required for waybar/rofi icons)
# -----------------------------------------------------
print_step "installing nerd fonts..."

NERD_FONTS_VERSION="v3.4.0"
FONTS_DIR="$HOME/.local/share/fonts"

install_nerd_font() {
    local font_name="$1"
    local zip_name="$2"
    if fc-list | grep -qi "$font_name"; then
        print_ok "$font_name already installed"
        return
    fi
    mkdir -p "$FONTS_DIR/$font_name"
    curl -LsSf "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/${zip_name}.zip" \
        -o "/tmp/${zip_name}.zip" 2>/dev/null && \
    unzip -qo "/tmp/${zip_name}.zip" -d "$FONTS_DIR/$font_name/" 2>/dev/null && \
    rm -f "/tmp/${zip_name}.zip" && \
    print_ok "installed $font_name" || print_warn "failed to install $font_name"
}

install_nerd_font "JetBrainsMono" "JetBrainsMono"
install_nerd_font "CascadiaCode" "CascadiaCode"

fc-cache -f "$FONTS_DIR" 2>/dev/null || true
print_ok "nerd fonts processed"

# -----------------------------------------------------
# step 3: backup existing configs
# -----------------------------------------------------
print_step "backing up existing configs to ${BACKUP_DIR}..."

mkdir -p "$BACKUP_DIR"

# config dirs that hyde will populate
CONFIG_DIRS=(
    hypr waybar dunst rofi kitty gtk-3.0
    Kvantum qt5ct qt6ct nwg-look fastfetch
    starship vim zsh fish xsettingsd wlogout uwsm systemd
)

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$HOME/.config/$dir" ]; then
        cp -r "$HOME/.config/$dir" "$BACKUP_DIR/.config-$dir"
        print_ok "backed up: .config/$dir"
    fi
done

# local dirs
LOCAL_DIRS=(
    .local/bin .local/lib/hyde
    .local/share/hyde .local/share/hypr
    .local/share/wallbash .local/share/waybar
    .local/share/icons .local/share/fastfetch
)

for dir in "${LOCAL_DIRS[@]}"; do
    if [ -d "$HOME/$dir" ]; then
        cp -r "$HOME/$dir" "$BACKUP_DIR/local-$(echo "$dir" | tr '/' '-')"
        print_ok "backed up: $dir"
    fi
done

# individual files
for f in .zshenv .gtkrc-2.0; do
    if [ -f "$HOME/$f" ]; then
        cp "$HOME/$f" "$BACKUP_DIR/"
        print_ok "backed up: $f"
    fi
done

print_ok "backup complete at ${BACKUP_DIR}"

# -----------------------------------------------------
# step 4: copy hyde configs to home
# -----------------------------------------------------
print_step "copying hyde configuration files..."

cp -r "${CONFIGS_DIR}/.config/." "$HOME/.config/"
cp -r "${CONFIGS_DIR}/.local/."  "$HOME/.local/"

[ -f "${CONFIGS_DIR}/.zshenv" ]    && cp "${CONFIGS_DIR}/.zshenv"    "$HOME/.zshenv"
[ -f "${CONFIGS_DIR}/.gtkrc-2.0" ] && cp "${CONFIGS_DIR}/.gtkrc-2.0" "$HOME/.gtkrc-2.0"

# make scripts executable
find "$HOME/.local/lib/hyde" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \; 2>/dev/null || true
find "$HOME/.local/bin"      -type f                                   -exec chmod +x {} \; 2>/dev/null || true

# fix hardcoded paths from original hyde author (/home/khing/)
print_step "fixing hardcoded paths..."
find "$HOME/.config" "$HOME/.local" -type f \( \
    -name "*.jsonc" -o -name "*.json" -o -name "*.css" \
    -o -name "*.conf" -o -name "*.sh" -o -name "*.ini" \
    -o -name "*.toml" -o -name "*.cfg" -o -name "*.kvconfig" \
    \) -exec sed -i "s|/home/khing/|${HOME}/|g" {} \; 2>/dev/null || true

print_ok "configs copied and paths fixed"

# -----------------------------------------------------
# step 5: copy wallbash cache placeholder
# -----------------------------------------------------
print_step "setting up wallbash cache..."

if [ -d "${CONFIGS_DIR}/.cache" ]; then
    mkdir -p "$HOME/.cache"
    cp -r "${CONFIGS_DIR}/.cache/." "$HOME/.cache/" 2>/dev/null || true
    print_ok "wallbash cache created"
fi

# -----------------------------------------------------
# step 6: create missing directories
# -----------------------------------------------------
print_step "creating required directories..."

mkdir -p "$HOME/.config/hyde/themes/wallpapers"
print_ok "theme directory ready"

# -----------------------------------------------------
# step 7: set up default wallpaper
# -----------------------------------------------------
print_step "setting up default wallpaper..."

# copy first available system wallpaper
WALLPAPER_SRC=""
for dir in /usr/share/backgrounds/kali-16x9 /usr/share/backgrounds/kali /usr/share/backgrounds; do
    if [ -d "$dir" ]; then
        WALLPAPER_SRC=$(find "$dir" -type f \( -name "*.jpg" -o -name "*.png" \) 2>/dev/null | head -1)
        [ -n "$WALLPAPER_SRC" ] && break
    fi
done

if [ -n "$WALLPAPER_SRC" ]; then
    cp "$WALLPAPER_SRC" "$HOME/.config/hyde/themes/wallpapers/wallpaper.jpg"
    print_ok "default wallpaper copied from system backgrounds"
else
    print_warn "no system wallpaper found; set one manually with: hyde-shell wallpaper"
fi

# -----------------------------------------------------
# step 8: configure gdm default session
# -----------------------------------------------------
print_step "configuring gdm to use hyprland as default session..."

ACCOUNTS_FILE="/var/lib/AccountsService/users/${USER}"

sudo tee "$ACCOUNTS_FILE" > /dev/null << ACCOUNTS_EOF
[User]
Session=hyprland.desktop
XSession=hyprland
SystemAccount=false
ACCOUNTS_EOF

print_ok "gdm default session set to hyprland"

# -----------------------------------------------------
# step 9: summary
# -----------------------------------------------------
cat << SUMMARY

    ==========================================
      installation complete
    ==========================================

    what was done:
      - installed hyprland and all required packages
      - backed up previous configs to:
        ${BACKUP_DIR}
      - copied hyde configs to your home directory
      - configured gdm to launch hyprland by default

    next steps:

      1. reboot your system:
         $ sudo reboot

      2. at the gdm login screen, verify the gear icon
         shows "hyprland" before entering your password

      3. if hyprland fails to start, select "gnome"
         from the gear menu to return to a working desktop

    troubleshooting:
      - logs: ~/.cache/hyde/logs/
      - hyprland log: check with 'journalctl -xe'
      - restore backup: manually copy files from ${BACKUP_DIR}
      - hyde wiki: https://hydeproject.pages.dev/

    credits:
      hyde project: https://github.com/HyDE-Project/HyDE
      hyprland:     https://hyprland.org/

    ==========================================

SUMMARY
