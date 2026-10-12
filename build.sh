#!/bin/bash
# Installs Tomo: builds Tomo.app, starts it at login, and (re)starts it now. Run it again after any change.
# Its own name, bundle id, login item and settings folder, so it never touches an installed Atticus.
set -e; cd "$(dirname "$0")"
NAME=Tomo
BUNDLE_ID=com.skinred78.tomo
CONFIG=~/.config/tomo
[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 26 ] || { echo "Tomo needs macOS 26 or later (it uses Apple's new on-device speech)."; exit 1; }
xcode-select -p >/dev/null 2>&1 || { echo "Needs Apple's command line tools. Run: xcode-select --install   then run ./build.sh again."; exit 1; }
command -v claude >/dev/null || [ -x ~/.local/bin/claude ] || echo "Note: Claude Code is not installed yet. The setup window will install it and sign you in."
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
# A compiler error must leave the installed app and its resources alone.
# -module-name: the code calls its own globals as Atticus.settings, and swiftc would otherwise name the module after the output (Tomo).
swiftc -O -target "$(uname -m)-apple-macos26.0" -module-name Atticus Atticus.swift -o "$STAGE/$NAME"
APP=~/Applications/$NAME.app   # in Applications so System Settings can list it for permissions
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/ui"
cp atticus.py "$APP/Contents/Resources/"
cp ui/*.html ui/*.js "$APP/Contents/Resources/ui/"
cp ui/AppIcon.icns "$APP/Contents/Resources/"
COMMIT=$(git log -1 --format='%h · %cd' --date=format:'%b %-d, %Y' 2>/dev/null || true)
cat > "$APP/Contents/Info.plist" <<P
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
<key>CFBundleName</key><string>Tomo</string>
<key>CFBundleDisplayName</key><string>Tomo</string>
<key>CFBundleExecutable</key><string>$NAME</string>
<key>CFBundleVersion</key><string>1</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>SourceCommit</key><string>$COMMIT</string>
<key>LSUIElement</key><true/>
<key>NSMicrophoneUsageDescription</key><string>Tomo listens when you use its shortcut or microphone button.</string>
<key>NSAppleEventsUsageDescription</key><string>Tomo controls apps like Finder, Chrome and Music when you ask it to.</string>
<key>NSSpeechRecognitionUsageDescription</key><string>Tomo turns your words into text on this Mac.</string>
</dict></plist>
P
mv "$STAGE/$NAME" "$APP/Contents/MacOS/$NAME"
# With a code-signing identity named "Tomo Local Signing" in the keychain, macOS keeps permissions across
# rebuilds; without one it signs ad hoc, and permissions must be granted again after each build.
ID=$(security find-identity -p codesigning | awk '/Tomo Local Signing/{print $2; exit}')
codesign -s "${ID:--}" --force "$APP"
# register with macOS, or System Settings can't list it for permissions
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP"
AGENT=~/Library/LaunchAgents/$BUNDLE_ID.plist   # starts at login, restarts if it crashes (Quit stays quit)
mkdir -p ~/Library/LaunchAgents "$CONFIG"
[ -f "$CONFIG/vocabulary.txt" ] || cp vocabulary.txt "$CONFIG/"   # speech hints; never overwrites your edits
python3 "$APP/Contents/Resources/atticus.py" --import-atticus || true   # your Atticus rules and shortcuts, copied once; Atticus is not touched
cat > "$AGENT" <<P
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>$BUNDLE_ID</string>
<key>ProgramArguments</key><array><string>$APP/Contents/MacOS/$NAME</string></array>
<key>RunAtLoad</key><true/>
<key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>
<key>StandardErrorPath</key><string>$CONFIG/app.err</string>
</dict></plist>
P
# Reload the job so launchd refreshes its executable signing requirement after a rebuild.
launchctl bootout gui/$(id -u)/$BUNDLE_ID 2>/dev/null || true
pkill -f "$APP/Contents/MacOS/$NAME$" 2>/dev/null && sleep 1   # stop a copy opened by hand too
# bootout can return before the job has finished unloading.
launchctl bootstrap gui/$(id -u) "$AGENT" 2>/dev/null || { sleep 1; launchctl bootstrap gui/$(id -u) "$AGENT"; }
echo "Tomo is running. Hold Control+Option+Space and talk."
