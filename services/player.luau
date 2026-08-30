--!nonstrict
-- Player state service for Noctalia Music Player.
-- Communicates with the Rust player binary via IPC (Unix socket) and cache file.
-- Responsibilities: track visibility, current track info, playback position.

local ipc = require("services.ipc")
local state = require("services.state")

local _current_title = ""
local _current_artist = ""
local _is_playing = false
local _position_secs = 0.0
local _duration_secs = 0.0
local _current_artwork = nil -- URL or path to album art

local function update_from_cache()
  -- Read visibility from cache file (authoritative)
  local visible = ipc.get_visibility()
  state.set_visible(visible)

  -- Read playback state from cache if available
  -- Note: The current Rust player does not expose real-time metadata via IPC.
  -- We only track what's determinable from the window visibility.
  if visible then
    -- Player window is visible; metadata might be available locally
    -- but without a status endpoint, we cannot reliably retrieve it.
    -- Fall back to default "Music Player" state.
    state.set_playing(false)
    state.set_title("🎵 Music Player")
    state.set_artist("")
    state.set_duration(0.0)
    state.set_position(0.0)
  else
    -- Player window is hidden; audio playback continues unchanged
    state.set_playing(false)
    state.set_title("🎵 Music Player")
    state.set_artist("")
    state.set_duration(0.0)
    state.set_position(0.0)
  end
end

local function update_from_ipc_status()
  -- Attempt to get status from Unix socket
  -- Currently returns nil since the player backend does not implement status
  local status = ipc.status()
  if status then
    -- If the player backend one day returns:
    --   { is_playing = bool, title = string, artist = string,
    --     position_secs = number, duration_secs = number, artwork = string }
    -- we would update the state here.
    -- For now, fall through to cache-based update.
  end
  update_from_cache()
end

--- Refresh the player state by reading the cache file and attempting IPC.
function state.refresh()
  update_from_ipc_status()
end

--- Get whether the player window is visible.
-- This is distinct from playback state. When hidden, audio continues.
-- @return boolean true if the player window is visible
function state.is_window_visible()
  return ipc.get_visibility()
end

--- Get the current playback state.
-- @return boolean true if audio is playing, false if paused/stopped
-- @note This reflects the last known state; without a status endpoint,
--       this is based on window visibility only.
function state.is_playing()
  return _is_playing
end

--- Get the current track title.
-- @return string track title, or "🎵 Music Player" if unavailable
function state.get_title()
  return _current_title
end

--- Get the current artist name.
-- @return string artist name, or "" if unavailable
function state.get_artist()
  return _current_artist
end

--- Get the current playback position in seconds.
-- @return number position in seconds
function state.get_position()
  return _position_secs
end

--- Get the current track duration in seconds.
-- @return number duration in seconds
function state.get_duration()
  return _duration_secs
end

--- Get the current album artwork.
-- @return string path or URL to artwork, or nil if unavailable
function state.get_artwork()
  return _current_artwork
end

--- Update playback state from external source (e.g., Tick subscription).
-- Called by the widget's update loop to keep position in sync.
-- @param playing true if currently playing
-- @param position_secs current position in seconds
-- @param duration_secs total track duration in seconds
-- @param title track title
-- @param artist track artist
-- @param artwork artwork path/URL
function state.update_state(playing, position_secs, duration_secs, title, artist, artwork)
  _is_playing = playing or false
  _position_secs = position_secs or 0.0
  _duration_secs = duration_secs or 0.0
  _current_title = title or "🎵 Music Player"
  _current_artist = artist or ""
  _current_artwork = artwork
  -- Persist updated state
  state.refresh()
end

-- Initialize: read initial state
update_from_cache()

return state