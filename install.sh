#!/bin/bash

set -euo pipefail

section() {
  echo ""; echo "$1"
}

# Zim (https://github.com/zimfw/zimfw)
if [ ! -f "${ZDOTDIR:-$HOME}/.zim/init.zsh" ]; then
  section "Zim Framework not found. Running installer.."
  curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
fi

# Mise (https://mise.jdx.dev/)
if ! command -v mise &> /dev/null; then
  section "Mise is not installed. Installing now.."
  /bin/bash -c "$(curl https://mise.run | sh)"
  eval "$(~/.local/bin/mise activate bash)"
fi

DOTS_DIR="$HOME/dots"
if [ ! -d "$DOTS_DIR" ]; then
  section "Cloning dotfiles repo.."
  git clone https://github.com/thomaswhyyou/dots "$DOTS_DIR"
  ln -sfn "$DOTS_DIR/config/mise" ~/.config/mise
fi

section "Install system packages:"
mise bootstrap packages apply -y

section "Install config files:"
mise bootstrap dotfiles apply -y --force

section "Install project packages:"
mise install; mise up

# Install fonts (note: requires `gh` to be installed first)
FONTS_DIR="$HOME/fonts"
if [ ! -d "$FONTS_DIR" ]; then
  section "Install fonts:"

  echo "Logging into GitHub..."
  gh auth login

  echo "Cloning fonts repo..."
  gh repo clone thomaswhyyou/fonts "$FONTS_DIR"

  (
    cd "$FONTS_DIR" || exit 1
    ./install.sh
  )
fi

# Install Brave browser extensions
if mise bootstrap packages status --json 2>/dev/null \
  | jq -e '.["brew-cask"].packages[] | select(.package == "brave-browser" and .state == "installed")' >/dev/null; then
  section "Install Brave extensions:"

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
  section "Syncing shell history (atuin):"
  atuin sync
fi

section "Finished."
