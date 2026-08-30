# Noctalia Music Player Widget

A fresh Noctalia bar widget for the standalone music player.

## Structure

```text
dw-ms-player-widget/
├── plugin.toml
├── bar.luau
└── README.md
```

The manifest follows the current Noctalia plugin format (`plugin_api = 24`) used by current community plugins.

## Install from Git

```bash
noctalia msg plugins source add music-player git https://github.com/dikawardani24/dw-ms-player-widget.git
```

Then refresh/list plugins:

```bash
noctalia msg plugins list
```

Enable:

```bash
noctalia msg plugins enable dikawardani24/music-player
```

Add this widget to the Noctalia bar:

```text
plugin:dikawardani24/music-player:bar
```

## Player integration

The widget intentionally does not implement playback. Clicking the widget executes:

```bash
noctalia-music-playerctl toggle
```

That command must be provided by the music-player application and must only toggle the player window:

```text
hidden  -> visible
visible -> hidden
```

It must never pause, stop, restart, or recreate playback.

This keeps window visibility independent from playback state.

## Development

The existing Noctalia Media Player and Spotify Media widgets were used only as API/architecture references. The widget implementation itself is fresh and intentionally minimal.
