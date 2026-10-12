#!/bin/bash
# Voice Assistant installer. The repo is private, so this clones it with your GitHub sign-in (gh or SSH):
#   git clone git@github.com:skinred78/voice-assistant.git ~/.voice-assistant && ~/.voice-assistant/install.sh
# Puts the source in ~/.voice-assistant, builds the app, opens it. It never updates itself: run this again to update.
set -e
DIR="${VOICE_ASSISTANT_DIR:-$HOME/.voice-assistant}"
REPO="${VOICE_ASSISTANT_REPO:-git@github.com:skinred78/voice-assistant.git}"
echo "Installing Voice Assistant…"
[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 26 ] || { echo "Voice Assistant needs macOS 26 or later."; exit 1; }
if ! xcode-select -p >/dev/null 2>&1; then
  echo "First, Apple's command line tools. A macOS window will open: click Install."
  echo "When it finishes, run the installer again."
  xcode-select --install 2>/dev/null || true
  exit 1
fi
if [ -d "$DIR/.git" ]; then
  git -C "$DIR" pull -q --ff-only || { echo "Could not update $DIR. Commit or stash your local changes, then run the installer again."; exit 1; }
else
  git clone -q "$REPO" "$DIR"
fi
"$DIR/build.sh"
open "$HOME/Applications/VoiceAssistant.app"
echo "Done. The setup window walks you through the rest."
