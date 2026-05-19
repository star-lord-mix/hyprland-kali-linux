# hyprland-kali-linux

<p align="center">
  <img src="https://raw.githubusercontent.com/HyDE-Project/HyDE/refs/heads/master/Source/assets/hyde_banner.png" alt="HyDE Banner" width="800">
</p>

<p align="center">
  <strong>HyDE (Hyprland Desktop Environment) adapted for Kali Linux</strong><br>
  A curated, heavily themed desktop environment built on Hyprland — now running on Debian-based systems.
</p>

---

## overview

This project brings the full [HyDE](https://github.com/HyDE-Project/HyDE) experience to **Kali Linux** (and other Debian-based distributions). Since HyDE is designed exclusively for Arch Linux, this adaptation handles package name differences, missing software, and display manager configuration so you get the same environment without Arch.

The installation script automates the entire process: package installation, configuration deployment from the bundled `configs/` directory, GDM setup, and backup of your existing dotfiles. No network required beyond `apt` — all HyDE dotfiles ship directly in this repository.

<p align="center">
  <img src="https://raw.githubusercontent.com/HyDE-Project/HyDE/refs/heads/master/Source/assets/showcase_1.png" alt="Showcase 1" width="400">
  <img src="https://raw.githubusercontent.com/HyDE-Project/HyDE/refs/heads/master/Source/assets/showcase_2.png" alt="Showcase 2" width="400">
</p>

## what you get

| component | description |
|-----------|-------------|
| **hyprland** | dynamic tiling wayland compositor (v0.54+) |
| **waybar** | customizable status bar with system tray |
| **rofi** | application launcher with theme support |
| **dunst** | notification daemon with styling |
| **hyprlock** | screen locker with blur and widget layouts |
| **hypridle** | idle management (dim, lock, suspend) |
| **kitty** | gpu-accelerated terminal emulator |
| **wallbash** | automatic theming from wallpaper colors |
| **18+ themes** | latte, mocha, gruvbox, tokyo, decay, and more |

<p align="center">
  <img src="https://raw.githubusercontent.com/HyDE-Project/HyDE/refs/heads/master/Source/assets/theme_select_1.png" alt="Theme Select" width="400">
  <img src="https://raw.githubusercontent.com/HyDE-Project/HyDE/refs/heads/master/Source/assets/rofi_style_sel.png" alt="Rofi Styles" width="400">
</p>

## requirements

- **kali linux rolling** (2025.x or later)
- **debian testing/unstable** may also work
- an active internet connection during installation
- at least **2 GB** of free disk space for packages and themes
- a user account with `sudo` privileges

> **note on gpu:** this setup works with intel, amd, and nvidia gpus. the hyde gpu detection scripts run at session start and configure environment variables automatically.

## quick install

```shell
git clone https://github.com/josafat-orozco/hyprland-kali-linux ~/hyprland-kali-linux
cd ~/hyprland-kali-linux
chmod +x install.sh
./install.sh
```

then reboot:

```shell
sudo reboot
```

at the gdm login screen, confirm the gear icon shows **hyprland** before entering your password.

## what the script does

1. **installs core packages** — `hyprland`, `hyprland-guiutils`, and 25+ supporting packages from kali repositories
2. **backs up configs** — saves your existing dotfiles to `~/configs-backup-YYYYMMDD-HHMMSS/`
3. **copies hyde configs** — deploys the bundled dotfiles, scripts, themes, and systemd user services from `configs/` to your home directory
4. **configures gdm** — sets hyprland as the default session via accountsservice
5. **prepares directories** — creates required theme and cache directories

### packages installed

```
hyprland
hyprland-guiutils
waybar
dunst
rofi
wlogout
hypridle
hyprlock
hyprsunset
hyprpicker
hyprpaper
hyprpolkitagent
grim
slurp
cliphist
nwg-look
qt5ct
qt6ct
qt-style-kvantum
qt-style-kvantum-themes
kitty
fastfetch
starship
fzf
jq
imagemagick
parallel
fonts-noto-color-emoji
uwsm
```

### packages not available in kali

| arch package | kali replacement | impact |
|-------------|-----------------|--------|
| `swww` | `hyprpaper` | wallpaper daemon — hyde auto-detects and uses hyprpaper instead |
| `satty` | _(none)_ | screenshot annotation tool — not critical |
| `kvantum` | `qt-style-kvantum` | same software, different package name |

## project structure

```
hyprland-kali-linux/
├── install.sh                     # automated installation script
├── README.md                      # this file
└── configs/                       # bundled hyde configuration (637 files, 26 MB)
    ├── .config/                   # hyprland, waybar, rofi, dunst, kitty, etc.
    ├── .local/                    # hyde scripts, wallpaper engine, themes
    ├── .zshenv                    # shell environment
    └── .gtkrc-2.0                 # gtk2 theme settings
```

the `configs/` directory contains the full hyde configuration tree sourced from the [HyDE repository](https://github.com/HyDE-Project/HyDE). it is self-contained — the install script copies from here, not from the network.

## keybindings

| shortcut | action |
|----------|--------|
| `Super` + `Q` | close focused window |
| `Super` + `R` | open application launcher (rofi) |
| `Super` + `Return` | open terminal (kitty) |
| `Super` + `E` | open file manager (dolphin) |
| `Super` + `V` | toggle floating window |
| `Super` + `W` | toggle floating mode |
| `Super` + `L` | lock screen |
| `Super` + `M` | exit hyprland |
| `Super` + `[1-0]` | switch to workspace 1-10 |
| `Super` + `Shift` + `[1-0]` | move window to workspace 1-10 |
| `Super` + `Scroll` | cycle workspaces |
| `Super` + `arrows` | move focus |
| `Ctrl` + `Alt` + `Delete` | logout menu |

full reference: `~/.config/hypr/keybindings.conf`

<p align="center">
  <img src="https://raw.githubusercontent.com/HyDE-Project/HyDE/refs/heads/master/Source/assets/showcase_3.png" alt="Showcase 3" width="400">
  <img src="https://raw.githubusercontent.com/HyDE-Project/HyDE/refs/heads/master/Source/assets/showcase_4.png" alt="Showcase 4" width="400">
</p>

## themes

hyde includes a wallpaper-based theming engine called **wallbash**. changing your wallpaper automatically regenerates color schemes for:

- gtk3 applications
- qt5 and qt6 (via kvantum)
- waybar
- rofi
- dunst notifications
- hyprlock
- kitty terminal
- wlogout
- vscode / vscodium

to switch themes:

```shell
hyde-shell theme.select
```

## file structure after installation

```
~/.config/
  hypr/           # hyprland configuration (userprefs, keybinds, monitors, etc.)
  waybar/         # status bar configuration and styles
  rofi/           # application launcher themes
  dunst/          # notification daemon config
  kitty/          # terminal emulator config
  wlogout/        # logout menu layout
  hyde/           # hyde core configuration (themes, wallbash)
  gtk-3.0/        # gtk3 theming settings
  qt5ct/          # qt5 theming
  qt6ct/          # qt6 theming
  Kvantum/        # kvantum svg theme engine
  nwg-look/       # gtk configuration tool state
  uwsm/           # wayland session manager environment

~/.local/
  bin/            # hyde cli tools (hyde-shell, hydectl, hyde-ipc)
  lib/hyde/       # hyde scripts (wallpaper, theme, screenshot, etc.)
  share/hyde/     # hyde data (templates, rofi themes, schema)
  share/hypr/     # generated hyprland config files
  share/waybar/   # waybar styles and includes
```

## troubleshooting

### hyprland does not start after login

- at gdm, click the gear icon and verify **hyprland** is selected (not gnome)
- check logs: `cat ~/.cache/hyde/logs/*.log`
- check hyprland log: `journalctl -xe | grep hyprland`
- fall back to gnome: select it from gdm gear menu

### black screen on boot

- switch to a tty with `Ctrl + Alt + F3`
- check if hyprland is installed: `which hyprland`
- verify gpu drivers: `lspci -k | grep -A 3 VGA`
- for nvidia: ensure `nvidia-dkms` or `nvidia-open-dkms` is installed

### wallpaper not changing

- hyde uses `hyprpaper` as the wallpaper daemon on kali (swww is not available)
- verify it is running: `pgrep hyprpaper`
- restart wallpaper: `hyde-shell wallpaper --start --global`

### waybar is empty or missing

- restart waybar: `hyde-shell waybar --restart`
- check waybar config: `~/.config/waybar/config.jsonc`
- verify fonts are installed: `fc-list | grep "Noto"`

### restore previous configs

```shell
# replace with your actual backup directory name
cp -r ~/configs-backup-YYYYMMDD-HHMMSS/.config-* ~/.config/
# reboot or restart session
```

## credits

- [HyDE Project](https://github.com/HyDE-Project/HyDE) — the original hyprland desktop environment for arch linux
- [Hyprland](https://hyprland.org/) — the dynamic tiling wayland compositor
- all screenshots and theme assets belong to the hyde project
- [Kali Linux](https://www.kali.org/) — the debian-based penetration testing distribution

## license

this adaptation script is provided as-is under the same terms as the hyde project. see the [original repository](https://github.com/HyDE-Project/HyDE) for full license details.
