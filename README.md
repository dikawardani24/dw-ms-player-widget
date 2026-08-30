# Noctalia Music Player Widget

A fresh Noctalia v5 bar widget for controlling the visibility of a standalone music-player UI.

## Design

The widget intentionally does **not** implement playback. It only sends a toggle command to the external music player.

```text
Noctalia Bar
     │
     ▼
 Music Player Widget
     │
     │ toggle
     ▼
Music Player UI
     │
     └── playback remains independent
```

Therefore:

```text
show  != play
hide  != pause
close != stop
```

## Install for development

Clone this repository somewhere convenient and add it as a Noctalia plugin source:

```bash
noctalia msg plugins source add dev path /path/to/dw-ms-player-widget
noctalia msg plugins enable dikawardani24/music-player
```

Then add the widget to your bar as:

```toml
end = ["plugin:dikawardani24/music-player:music-player"]
```

## Player command

The default command is:

```text
dw-ms-player-widget toggle
```

Change it in Noctalia widget settings if the installed player exposes a different command.

The command must implement a true UI toggle:

```text
hidden → visible
visible → hidden
```

It must not pause, stop, restart, or recreate the audio player.

## IPC

The widget also accepts:

```bash
noctalia msg plugin dikawardani24/music-player:music-player focused toggle
```

which performs the same toggle operation.
