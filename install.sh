#!/bin/bash

set -euo pipefail

put() {
  echo ""; echo "$1"
}

# --- Zsh + Zim

# Zim (https://github.com/zimfw/zimfw)
if [ ! -f "${ZDOTDIR:-$HOME}/.zim/init.zsh" ]; then
  echo "Zim Framework not found. Running installer.."
  curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
fi

ZSHRC="$HOME/.zshrc"
echo "Setting up $ZSHRC"
if touch $ZSHRC && ! grep -Fxq "source ~/.profile" "$ZSHRC"; then
  echo "" >> "$ZSHRC"
  echo "# Added by $(readlink -f "$0") on $(date +%F)." >> "$ZSHRC"
  echo "source ~/.profile" >> "$ZSHRC"
fi

# --- Mise

# Mise (https://mise.jdx.dev/)
if ! command -v mise &> /dev/null; then
  echo "Mise is not installed. Installing now.."
  /bin/bash -c "$(curl https://mise.run | sh)"
fi

MISE_CONFIG="$HOME/.config/mise/config.toml"
if [ ! -f "$MISE_CONFIG" ]; then
  put "Fetching mise config.."
  mkdir -p "$(dirname "$MISE_CONFIG")"
  curl -fsSL https://raw.githubusercontent.com/thomaswhyyou/dots/main/config/mise/config.toml -o "$MISE_CONFIG"
fi

put "Install system packages:"
mise bootstrap packages apply -y

put "Install config repos:"
mise bootstrap repos apply -y

put "Install config files:"
mise bootstrap dotfiles apply -y --force

put "Install project packages:"
mise install; mise up

# Note: requires `gh` to be installed from homebrew first
FONTS_DIR="$HOME/fonts"
if [ ! -d "$FONTS_DIR" ]; then
  put "Install fonts:"

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
  put "Install Brave extensions:"

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
  put "Syncing shell history (atuin):"
  atuin sync
fi

put "Finished."
