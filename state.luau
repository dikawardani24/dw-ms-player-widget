--!nonstrict
-- Global player state management for the Noctalia music player widget.

local M = {}

M.visible = false
M.is_playing = false
M.title = "🎵 Music Player"
M.artist = ""
M.artwork = nil
M.duration_secs = 0.0
M.position_secs = 0.0
M.volume = 0.5

function M.set_visible(visible)
  M.visible = visible ~= false
end

function M.set_playing(playing)
  M.is_playing = playing ~= false
end

function M.set_title(title)
  M.title = title or "🎵 Music Player"
end

function M.set_artist(artist)
  M.artist = artist or ""
end

function M.set_artwork(artwork)
  M.artwork = artwork
end

function M.set_duration(duration)
  M.duration_secs = duration or 0.0
end

function M.set_position(position)
  M.position_secs = position or 0.0
end

function M.set_volume(volume)
  M.volume = volume ~= nil and math.max(0, math.min(1, volume)) or 0.5
end

function M.init()
  local ok, visible = pcall(function()
    return require("ipc").get_visibility()
  end)
  if ok then
    M.visible = visible
  end
end

function M.refresh()
  -- Refresh from cache and IPC
end

return M