#!/bin/bash

set -euo pipefail

# Mise (https://mise.jdx.dev/)
if ! command -v mise &> /dev/null; then
  echo "Mise is not installed. Installing now.."
  /bin/bash -c "$(curl https://mise.run | sh)"
fi

# Zim (https://github.com/zimfw/zimfw)
if [ ! -f "${ZDOTDIR:-$HOME}/.zim/init.zsh" ]; then
  echo "Zim Framework not found. Running installer.."
  curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
fi

# --- Symlinks ---

echo ""; echo "Symlink dotfiles:"
DOTFILES="
.profile
.gitconfig
.tmux.conf
.psqlrc
"
for file in $DOTFILES; do
  echo "Creating a symlink to $file in home"
  ln -sfn "./dots/$file" ~/$(basename $file)
done

CONFIGS="
ghostty
karabiner
nvim
mise
jj
"
for dir in $CONFIGS; do
  echo "Creating a symlink at ~/.config/$dir"
  ln -sfn ~/dots/config/$dir ~/.config/$dir
done

# Atuin keeps (re)creating a directory with the default config.
ln -sf ~/dots/config/atuin/config.toml ~/.config/atuin/config.toml

ZSHRC="$HOME/.zshrc"
echo "Setting up $ZSHRC"
if touch $ZSHRC && ! grep -Fxq "source ~/.profile" "$ZSHRC"; then
  echo "" >> "$ZSHRC"
  echo "# Added by $(readlink -f "$0") on $(date +%F)." >> "$ZSHRC"
  echo "source ~/.profile" >> "$ZSHRC"
fi

# --- Packages ---

echo ""; echo "Install system packages (mise):"
mise bootstrap
echo ""; echo "Install project packages (mise):"
mise install; mise up

# Note: requires `gh` to be installed from homebrew first
FONTS_DIR="$HOME/fonts"
if [ ! -d "$FONTS_DIR" ]; then
  echo ""; echo "Install fonts:"

  echo "Logging into GitHub..."
  gh auth login

  echo "Cloning fonts repo..."
  gh repo clone thomaswhyyou/fonts "$FONTS_DIR"

  (
    cd "$FONTS_DIR" || exit 1
    ./install.sh
  )
fi

# Brave browser extensions
if mise bootstrap packages status --json 2>/dev/null \
  | jq -e '.["brew-cask"].packages[] | select(.package == "brave-browser" and .state == "installed")' >/dev/null; then
  echo ""; echo "Install Brave extensions:"

  BRAVE_EXT_DIR="$HOME/Library/Application Support/BraveSoftware/Brave-Browser/External Extensions"
  mkdir -p "$BRAVE_EXT_DIR"

  EXTENSION_IDS=(
    "dbepggeogbaibhgnhhndojpepiihcmeb"  # Vimium
    "nngceckbapebfimnlniiiahkandclblb"  # Bitwarden
    "nmdgidofjbajhphomaniiekgckpioifp"  # Color Changer
  )
  for ext_id in "${EXTENSION_IDS[@]}"; do
    if [[ ! -f "${BRAVE_EXT_DIR}/${ext_id}.json" ]]; then
      echo "Registering: ${ext_id}"
      echo '{"external_update_url": "https://clients2.google.com/service/update2/crx"}' > "${BRAVE_EXT_DIR}/${ext_id}.json"
    else
      echo "Registered: ${ext_id}"
    fi
  done
fi

# Shell history sync
if command -v atuin >/dev/null 2>&1; then
  echo ""; echo "Syncing shell history (atuin):"
  atuin sync
fi

echo ""; echo "Finished."
