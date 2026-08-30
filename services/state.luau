--!nonstrict
-- Global player state management for the Noctalia music player widget.
-- Conceptually supports: running, playing, title, artist, artwork, duration, position, volume, playlist.
-- But gracefully degrades when player state is unavailable.

local M = {}

-- Visibility state: whether the player window is shown/hidden
-- Distinct from playback state. When hidden, audio continues.
M.visible = false

-- Playback state
M.is_playing = false
M.title = "🎵 Music Player"
M.artist = ""
M.artwork = nil
M.duration_secs = 0.0
M.position_secs = 0.0
M.volume = 0.5
M.playlist_index = 1
M.playlist = {}

-- Track whether we've initialized from cache
M._initialized = false

-- Set visibility state
function M.set_visible(visible)
  M.visible = visible ~= false
  -- Do NOT modify playback state when visibility changes
  -- This is the hard requirement: window visibility ≠ playback state
end

-- Set playing state (called from Tick or external updates)
function M.set_playing(playing)
  M.is_playing = playing ~= false
end

-- Set track title
function M.set_title(title)
  M.title = title or "🎵 Music Player"
end

-- Set artist name
function M.set_artist(artist)
  M.artist = artist or ""
end

-- Set artwork
function M.set_artwork(artwork)
  M.artwork = artwork
end

-- Set duration
function M.set_duration(duration)
  M.duration_secs = duration or 0.0
end

-- Set position
function M.set_position(position)
  M.position_secs = position or 0.0
end

-- Set volume (0.0 - 1.0)
function M.set_volume(volume)
  M.volume = volume ~= nil and math.max(0, math.min(1, volume)) or 0.5
end

-- Set playlist
function M.set_playlist(tracks)
  M.playlist = tracks or {}
  if #M.playlist > 0 then
    M.playlist_index = M.playlist_index <= #M.playlist and M.playlist_index or 1
  end
end

-- Get whether the player window is visible
function M.is_window_visible()
  return M.visible
end

-- Get playing state
function M.is_playing()
  return M.is_playing
end

-- Get title
function M.get_title()
  return M.title
end

-- Get artist
function M.get_artist()
  return M.artist
end

-- Get artwork
function M.get_artwork()
  return M.artwork
end

-- Get duration
function M.get_duration()
  return M.duration_secs
end

-- Get position
function M.get_position()
  return M.position_secs
end

-- Get volume
function M.get_volume()
  return M.volume
end

-- Get playlist
function M.get_playlist()
  return M.playlist
end

-- Get current track index
function M.get_playlist_index()
  return M.playlist_index
end

-- Initialize from cache file on module load
function M.init()
  if not M._initialized then
    local visible = require("services.ipc").get_visibility()
    M.visible = visible
    M._initialized = true
  end
end

-- Refresh state from cache and IPC
function M.refresh()
  require("services.player").refresh()
end

return M