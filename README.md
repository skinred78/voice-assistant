# Voice Assistant

Sam's own macOS voice assistant. Hold <kbd>⌃ control</kbd> <kbd>⌥ option</kbd> <kbd>space</kbd>, say what you need, let go. It launches apps, finds files, moves windows and reads the screen, using Apple's on-device speech and the Claude Code CLI on your Claude plan.

It started as a fork of [Atticus](https://github.com/SaarthurR/atticus-mac) by SaarthurR, imported at commit `39c27c9` (11 Oct 2026), when the whole project was MIT licensed. The original copyright notice is kept in `LICENSE`.

## What differs from Atticus

- No telemetry. The PostHog daily-user ping and its setting are gone.
- No self-update. The app never pulls or rebuilds itself. To update, pull this repo and run `./build.sh`.
- No licence key. The Gumroad key check is gone.
- Its own identity, so it can run beside an installed Atticus or replace it: app `~/Applications/VoiceAssistant.app`, bundle id `com.skinred78.voice-assistant`, login item `~/Library/LaunchAgents/com.skinred78.voice-assistant.plist`, settings and history in `~/.config/voice-assistant`, installed source in `~/.voice-assistant`.

Both apps use Control+Option+Space by default. If you run them side by side, change the shortcut in one of them (Settings → General) or quit Atticus.

## Install

You need macOS 26 or later, a paid Claude plan with [Claude Code](https://claude.com/claude-code), and Apple's command line tools (`xcode-select --install`). [Peekaboo](https://github.com/openclaw/Peekaboo) is optional, for clicking inside apps.

The repo is private, so clone it with your GitHub sign-in, then run the installer:

```
git clone git@github.com:skinred78/voice-assistant.git ~/.voice-assistant && ~/.voice-assistant/install.sh
```

Working on the code? Clone it anywhere and run `./build.sh` after each change.

The first launch opens a setup window that checks your Claude plan and asks for each macOS permission. To see it again: `defaults delete com.skinred78.voice-assistant onboarded`, then restart the app. Errors go to `~/.config/voice-assistant/app.err`.

Remove: `launchctl bootout gui/$(id -u)/com.skinred78.voice-assistant`, then delete `~/Applications/VoiceAssistant.app`, `~/.voice-assistant`, `~/.config/voice-assistant` and `~/Library/LaunchAgents/com.skinred78.voice-assistant.plist`.

## Tests

`python3 -m unittest discover -s tests -v` runs the offline regressions (CI runs these too). On macOS, `python3 atticus.py --selftest` checks the brain, and after building, `~/Applications/VoiceAssistant.app/Contents/MacOS/VoiceAssistant --selftest` checks native transcript matching. For the UI checks, run `python3 -m http.server 8765 --bind 127.0.0.1` and open `http://127.0.0.1:8765/tests/ui.html` or `tests/settings.html`.

## Budget

Inherited from Atticus and still enforced: instant commands use no AI; AI asks should stay under a median of $0.002 and 6 s (`python3 atticus.py --budget`); the system prompt stays under 10,000 characters (a test checks it).

## Files

- `Atticus.swift`: the app (hotkey, speech, overlay, setup and Settings windows)
- `atticus.py`: the brain (instant commands, system prompt, helpers for windows, web and screen)
- `ui/ui.html`, `ui/onboarding.html`, `ui/settings.html`: the overlay, the setup flow and Settings
- `ui/orbs.js`: the [thinking-orbs](https://github.com/Jakubantalik/thinking-orbs) engine (MIT, Jakub Antalik)

The source files keep their Atticus names for now, so upstream fixes from the MIT version stay easy to compare.

## Licence and credit

MIT. See `LICENSE`. Based on [Atticus](https://github.com/SaarthurR/atticus-mac), Copyright (c) 2026 SaarthurR, MIT. `ui/orbs.js` is from thinking-orbs, also MIT.
