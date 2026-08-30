# DW Music Player — Noctalia Plugin

Native Noctalia music player bar widget with popup controls, playlist, and fixed-height visualizer.

## Features

* **Native Noctalia bar widget** — music icon in the bar, click to toggle player
* **Music player popup** — full player UI with album art, controls, visualizer, and playlist
* **Hide/show without stopping playback** — window visibility is independent from audio state
* **Player controls** — Previous, Play/Pause, Next (configurable commands)
* **Playlist support** — expandable/collapsible, scrollable, current track identifiable
* **Fixed-height visualizer** — container height stays constant; bars animate inside
* **Dark/light theme support** — uses Noctalia theme tokens (surface, on_surface, primary, etc.)

## Installation

The plugin uses Noctalia plugin API v13. Install from the local repository:

```bash
# Add the plugin source
noctalia msg plugins source add music-player git \
  https://github.com/dikawardani24/dw-ms-player-widget.git

# Refresh the plugin list
noctalia msg plugins list

# Enable the plugin
noctalia msg plugins enable dikawardani24/music-player
```

After enabling, add the bar widget to your Noctalia bar configuration:

```text
plugin:dikawardani24/music-player:bar
```

## Development

### Plugin structure

```
dw-ms-player-widget/
├── plugin.toml          # Manifest (API v13)
├── entries/bar.luau     # Bar widget entry point
├── services/            # Logic services
│   ├── ipc.luau         # Unix socket IPC client
│   ├── player.luau      # Player state & communication
│   └── state.luau       # Global state management
├── popup/               # Noctalia panel (popup/remote control)
│   ├── popup.luau       # Main panel render & lifecycle
│   ├── controls.luau    # Previous/Play/Pause/Next
│   ├── playlist.luau    # Expandable playlist section
│   └── animations.luau  # Fixed-height visualizer
├── assets/              # Plugin assets
│   └── icon.svg         # Plugin icon
└── locales/             # Localized strings
    └── en.toml          # English translations

### Noctalia API version

This plugin targets **Noctalia API v13**. Key API references:

* `plugin_api = 13` in `plugin.toml` — must match installed Noctalia version
* `barWidget.render(element)` / `barWidget.setTooltip(text)` — bar widget API
* `panel.render(content)` / `panel.close()` / `panel.open()` — panel/popup API
* `noctalia.runAsync(command)` — execute shell commands
* `noctalia.togglePanel(id)` — toggle a panel by plugin ID
* `noctalia.state.get/set/watch()` — plugin state channel
* `noctalia.getConfig(key)` / `noctalia.setConfig(key, value)` — plugin settings
* `noctalia.tr(key)` / `noctalia.notify(msg)` — i18n and notifications
* `noctalia.pluginDir()` / `noctalia.pluginDataDir()` — plugin directory paths
* `noctalia.setUpdateInterval(ms)` — update loop scheduling

### Player integration

This plugin communicates with the [Noctalia Music Player](https://github.com/dikawardani24/noctalia-music-player)
Rust binary via Unix socket IPC. The player must be running for the widget to function.

**IPC protocol** (Unix socket at `$XDG_RUNTIME_DIR/noctalia-music-player.sock`):

| Command | Effect |
|---------|--------|
| `toggle` | Show/hide player window (does NOT affect playback) |
| `show`   | Force show player window |
| `hide`   | Force hide player window |
| `play-pause` | Toggle playback (requires backend support) |
| `next`   | Play next track (requires backend support) |
| `prev`   | Play previous track (requires backend support) |
| `status` | Request current playback state (not yet implemented) |

**Cache file** — `/home/dika/.cache/noctalia-music-player-visible`
The plugin reads this file to determine whether the player window is visible.
The file contains `1` (visible) or `0` (hidden). This is the authoritative source
for window visibility state.

**Required player CLI flags** (currently supported):

* `noctalia-music-player --toggle` — toggle window visibility
* `noctalia-music-player --show` — show window
* `noctalia-music-player --hide` — hide window

**Player features to add** (for full control support):

* `--play-pause` CLI flag and `play-pause` Unix socket command
* `--next` CLI flag and `next` Unix socket command
* `--prev` CLI flag and `prev` Unix socket command
* `--status` CLI flag and `status` Unix socket command with JSON response

### IPC/MPRIS

This plugin uses a custom Unix socket IPC protocol with the Noctalia Music Player
Rust binary. MPRIS is not implemented — the player does not expose MPRIS metadata.
Future integration could add MPRIS as an additional state source, but the current
widget works with the existing IPC protocol alone.

## Troubleshooting

### Plugin does not appear in the list

* Verify the plugin was enabled: `noctalia msg plugins enable dikawardani24/music-player`
* Check that `plugin_api = 13` matches your Noctalia version
* Ensure the plugin source was added correctly: `noctalia msg plugins list` should show `dikawardani24/music-player`

### Widget does not appear in the bar

* Ensure the bar configuration includes `plugin:dikawardani24/music-player:bar`
* Verify the plugin is enabled before adding the widget to the bar
* Check `noctalia msg plugins list` for any error messages

### Player not detected

* Ensure the Noctalia Music Player binary is installed and running
* Check that the cache file exists: `cat ~/.cache/noctalia-music-player-visible`
  * Should contain `1` (visible) or `0` (hidden)
* Verify the player binary is executable: `which noctalia-music-player`
* Ensure the Unix socket exists: `ls /run/user/1000/noctalia-music-player.sock`

### IPC unavailable

* If the Unix socket is unavailable, the plugin gracefully degrades:
  * The bar widget shows the music icon with tooltip "Music Player"
  * Clicking the bar toggles the Noctalia popup panel
  * Player controls (Prev/Play/Pause/Next) are shown but may not affect playback
  * The popup shows "🎵 Music Player" when state cannot be retrieved
* No uncaught errors should take down the widget — all IPC calls are protected