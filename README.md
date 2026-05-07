# qlab-scripts

A small collection of AppleScripts for [QLab 5](https://qlab.app) that I use to make show-building faster.

All scripts are plain text — read them before you run them.

## Scripts

### 1. `sort-group-alphabetically.applescript`

Sorts the cues inside the **selected Group cue** alphabetically by cue name (A–Z, then digits/symbols).

**Use case:** I keep playlists inside Group cues and want them sorted alphabetically by name regardless of cue number, without having to drag cues around by hand.

**Behavior:**
- Requires exactly **one** selected cue, and it must be a Group.
- Sorts only the immediate children of that group. Nested group cues are sorted like other immediate children, but their internal contents are untouched.
- Sort is **case-insensitive**. Names starting with a letter come before names starting with a digit or symbol.
- Cue numbers are ignored — only the cue **name** matters.

### 2. `normalize-lufs.applescript`

For each selected **Audio cue**, measures the audio file's integrated loudness with `r128x-cli` and sets the cue's main fader so the cue plays back at a target LUFS.

**Use case:** Mixed bag of source files at all kinds of levels? Select them all, run the script, walk away. Each cue's fader is set so it plays at your reference level (default `-14 LUFS`).

**Behavior:**
- Skips anything in the selection that isn't an Audio cue.
- Writes the measured LUFS and the applied dB adjustment into each cue's notes (so you can audit later).
- Two values at the top of the script are user-configurable:
  - `theReferenceLevel` — your target integrated LUFS (default `-14`).
  - `thefaderLevel` — the dB the main fader should sit at for cues already at the reference (default `0`).

**Requires** [`r128x-cli`](https://github.com/manuelnaudin/r128x) installed at `/usr/local/bin/r128x-cli`. If yours lives elsewhere (e.g. `/opt/homebrew/bin/r128x-cli` on Apple Silicon), update the path in the script.

---

## Installation

```sh
git clone https://github.com/alfarolabs/qlab-scripts.git
```

You can keep the files anywhere — they're just plain `.applescript` source.

## How to run a script

Pick whichever fits your workflow:

### A. Run from inside QLab (recommended)

This is the fastest for repeated use. The script lives inside your workspace and you trigger it like any other cue.

1. In QLab, create a **Script cue**.
2. Open the script `.applescript` file in **Script Editor** (or any text editor) and copy its contents.
3. Paste into the Script cue's editor in QLab.
4. Click **Compile**. Save the workspace.
5. Trigger the Script cue (GO, hotkey, MIDI, OSC, hardware key, etc.) whenever you want to run it.

### B. Run from Script Editor

Useful for one-offs or testing.

1. Double-click the `.applescript` file → it opens in Script Editor.
2. Make sure your QLab workspace is open.
3. Click **Run** (▶) in Script Editor.

### C. Run from the menu bar

If you want it accessible globally:

1. In Script Editor, open the file.
2. **System Settings → Control Center → Scripts Menu** (enable it).
3. Save the script into `~/Library/Scripts/` so it shows up in the system Scripts menu.

---

## Macros / hotkeys

For `sort-group-alphabetically`, I recommend assigning a hotkey to its Script cue inside the QLab workspace (in the cue's Triggers tab). One key, instant sort.

For `normalize-lufs`, the script shows a confirmation dialog before doing anything destructive, so a hotkey is safe too.

---

## Compatibility

- Tested on **QLab 5.5.10** on macOS (Apple Silicon).
- Should work on any QLab 5.x release; the AppleScript dictionary used here is stable.
- Will **not** work on QLab 4 (the dictionary differs; e.g. `setLevel` is QLab 5).

## Caveats

- Always test on a duplicate of an important workspace first.
- AppleScript actions in QLab 5 are undoable (⌘Z), but better safe than sorry.

## License

MIT — do whatever you want, no warranty.
