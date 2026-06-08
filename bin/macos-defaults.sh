#!/bin/bash

# Configure macos with better settings.
#
# Many settings require a logout or restart to take effect. Some settings may
# require closing the affected app first.
#
# References:
#   https://macos-defaults.com/

set -euo pipefail

echo "Applying macOS defaults..."

# Close System Settings to prevent it from overriding changes
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# --- Keyboard & Trackpad ---

# Trackpad speed (0 to 3, the default is "1")
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3.0

# Fast key repeat rate (slider values, lower equals faster)
# KeyRepeat: 120, 90, 60, 30, 12, 6, 2
# InitialKeyRepeat: 120, 94, 68, 35, 25, 15
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Use F1, F2, etc. as standard function keys
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# --- Dock ---

# Autohide the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Speed up the Dock hide/show animation
defaults write com.apple.dock autohide-time-modifier -float 0.15

# Minimize using scale effect
defaults write com.apple.dock mineffect -string "scale"

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Set icon size
defaults write com.apple.dock tilesize -int 36

# Disable hot corners (wvous-bl-corner = 1 means disabled)
defaults write com.apple.dock wvous-tl-corner -int 1
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-br-corner -int 1

# --- Finder ---

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Default to list view
# icnv = icon, clmv = column, Nlsv = list, glyv = gallery
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# New Finder window opens home directory
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# --- Misc ---

# Save to disk (not iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable automatic text corrections
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo ""; echo "Done. Restarting affected apps..."

for app in "Dock" "Finder" "SystemUIServer"; do
  killall "${app}" 2>/dev/null || true
done

echo "Some changes require a logout/restart to take effect."

# TODO: import RectangleConfig
