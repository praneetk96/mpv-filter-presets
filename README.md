# mpv-filter-presets
Interactive filter preset menu for mpv (F6) with preview and quick switching.

Interactive filter preset menu for **mpv** that lets you quickly switch between different video enhancement profiles.

The script provides a simple on-screen menu to preview and apply presets that combine color adjustments, sharpening, and debanding.

---

## Features

- Interactive preset menu
- Preview presets before applying
- Multiple built-in video enhancement presets
- Debanding and sharpening filters
- Non-destructive preview (ESC restores previous state)
- Lightweight Lua script

---

## Included Presets

- None
- Cinematic
- Cool Tone
- Custom
- Deep Black
- Dramatic
- Ghibli Style
- Neon Pop
- Night Mode
- Nostalgic
- Sharpen
- Soft Pastel
- Vivid
- Warm Tone

---

## Installation

1. Locate your mpv configuration directory.

### Windows

`%APPDATA%\mpv\scripts\`

### Linux / macOS

`~/.config/mpv/scripts/`

2. Copy the script file:

`mpv-filter-presets.lua`

into the `scripts` folder.

3. Restart mpv.

---

## Usage

Press: `F6`

Controls:

↑ / ↓ Preview presets >> Enter Apply preset >> ESC Cancel
