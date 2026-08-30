--!nonstrict
-- Player state service for Noctalia Music Player.
-- Communicates with the Rust player binary via IPC (Unix socket) and cache file.

local ipc = require("services.ipc")
local state = require("services.state")

local _current_title = ""
local _current_artist = ""
local _is_playing = false
local _position_secs = 0.0
local _duration_secs = 0.0
local _current_artwork = nil

local function update_from_cache()
  local visible = ipc.get_visibility()
  state.set_visible(visible)
  if visible then
    state.set_playing(false)
    state.set_title("🎵 Music Player")
    state.set_artist("")
    state.set_duration(0.0)
    state.set_position(0.0)
  else
    state.set_playing(false)
    state.set_title("🎵 Music Player")
    state.set_artist("")
    state.set_duration(0.0)
    state.set_position(0.0)
  end
end

local function update_from_ipc_status()
  local status = ipc.status()
  if status then
    -- Would update state from status here
  end
  update_from_cache()
end

function state.refresh()
  update_from_ipc_status()
end

function state.is_window_visible()
  return ipc.get_visibility()
end

function state.is_playing()
  return _is_playing
end

function state.get_title()
  return _current_title
end

function state.get_artist()
  return _current_artist
end

function state.get_position()
  return _position_secs
end

function state.get_duration()
  return _duration_secs
end

function state.get_artwork()
  return _current_artwork
end

function state.update_state(playing, position_secs, duration_secs, title, artist, artwork)
  _is_playing = playing or false
  _position_secs = position_secs or 0.0
  _duration_secs = duration_secs or 0.0
  _current_title = title or "🎵 Music Player"
  _current_artist = artist or ""
  _current_artwork = artwork
  state.refresh()
end

update_from_cache()

return state