# Tomo

Sam's own macOS voice assistant. Hold <kbd>⌃ control</kbd> <kbd>⌥ option</kbd> <kbd>space</kbd>, say what you need, let go. It launches apps, finds files, moves windows and reads the screen, using Apple's on-device speech and the Claude Code CLI on your Claude plan.

It started as a fork of [Atticus](https://github.com/SaarthurR/atticus-mac) by SaarthurR, imported at commit `39c27c9` (11 Oct 2026), when the whole project was MIT licensed. The original copyright notice is kept in `LICENSE`.

## What differs from Atticus

- No telemetry. The PostHog daily-user ping and its setting are gone.
- No self-update. The app never pulls or rebuilds itself. To update, pull this repo and run `./build.sh`.
- No licence key. The Gumroad key check is gone.
- Its own identity, so it can run beside an installed Atticus or replace it: app `~/Applications/Tomo.app`, bundle id `com.skinred78.tomo`, login item `~/Library/LaunchAgents/com.skinred78.tomo.plist`, settings and history in `~/.config/tomo`, installed source in `~/.tomo`.

- Australian English speech. Recognition runs in `en-AU` (set `"locale"` in `~/.config/tomo/settings.json` to change it). Words it should expect, such as Japanese words, names and brands, go in `~/.config/tomo/vocabulary.txt`, one per line.
- Instant file search with no AI. "Find my budget spreadsheet", "where is the Tokyo deck" or "open my invoice file" runs Spotlight directly. Files whose names match come first, then the most recently used. One hit opens (or, for "where is", shows in Finder); several show the choices card, and "open the second one" works for ten minutes after. "Find pricing in Obsidian" searches only the vault and opens the note in Obsidian. A search that finds nothing goes to Claude.
- Voice notes into Obsidian with no AI. "Note that…", "capture…" or "remind me to…" adds a timestamped bullet, in your own words, at the end of `## Capture` in today's daily note (`<vault>/Daily Notes/YYYY-MM-DD.md`). It only ever adds a line. With no daily note yet, the note goes to `CMO/_capture/voice-inbox.md`. The vault is `~/obsidian-vault` unless `"vault"` (and `"dailyNotes"` for the folder) says otherwise in `settings.json`.
- One safety check on every tool, not just shell commands. Claude may read files only in the vault, Documents, Desktop and Downloads; keys, passwords and browser data are never touched, even by a shell command; and a web request that carries data in its address shows the Allow card first.
- Your Atticus memory comes along. The first build copies your Atticus rules, facts and learned shortcuts from `~/.config/atticus` into `~/.config/tomo` (Atticus's own files are only read), and points the shortcuts at Tomo.

Both apps use Control+Option+Space by default. If you run them side by side, change the shortcut in one of them (Settings → General) or quit Atticus.

## Install

You need macOS 26 or later, a paid Claude plan with [Claude Code](https://claude.com/claude-code), and Apple's command line tools (`xcode-select --install`). [Peekaboo](https://github.com/openclaw/Peekaboo) is optional, for clicking inside apps.

The repo is private, so clone it with your GitHub sign-in, then run the installer:

```
git clone git@github.com:skinred78/voice-assistant.git ~/.tomo && ~/.tomo/install.sh
```

Working on the code? Clone it anywhere and run `./build.sh` after each change.

The first launch opens a setup window that checks your Claude plan and asks for each macOS permission. To see it again: `defaults delete com.skinred78.tomo onboarded`, then restart the app. Errors go to `~/.config/tomo/app.err`.

Remove: `launchctl bootout gui/$(id -u)/com.skinred78.tomo`, then delete `~/Applications/Tomo.app`, `~/.tomo`, `~/.config/tomo` and `~/Library/LaunchAgents/com.skinred78.tomo.plist`.

## Tests

`python3 -m unittest discover -s tests -v` runs the offline regressions (CI runs these too). On macOS, `python3 atticus.py --selftest` checks the brain, and after building, `~/Applications/Tomo.app/Contents/MacOS/Tomo --selftest` checks native transcript matching. For the UI checks, run `python3 -m http.server 8765 --bind 127.0.0.1` and open `http://127.0.0.1:8765/tests/ui.html` or `tests/settings.html`.

## Budget

Inherited from Atticus and still enforced: instant commands use no AI; AI asks should stay under a median of $0.002 and 6 s (`python3 atticus.py --budget`); the system prompt stays under 10,000 characters (a test checks it).

## Files

- `Atticus.swift`: the app (hotkey, speech, overlay, setup and Settings windows)
- `atticus.py`: the brain (instant commands, system prompt, helpers for windows, web and screen)
- `ui/ui.html`, `ui/onboarding.html`, `ui/settings.html`: the overlay, the setup flow and Settings
- `ui/orbs.js`: the [thinking-orbs](https://github.com/Jakubantalik/thinking-orbs) engine (MIT, Jakub Antalik)
- `vocabulary.txt`: the starting speech vocabulary, copied to `~/.config/tomo/` on the first build

The source files keep their Atticus names for now, so upstream fixes from the MIT version stay easy to compare. `build.sh` compiles with `-module-name Atticus` for the same reason.

## Licence and credit

MIT. See `LICENSE` and `NOTICE`. Based on [Atticus](https://github.com/SaarthurR/atticus-mac), Copyright (c) 2026 SaarthurR, MIT. `ui/orbs.js` is from thinking-orbs, also MIT.
