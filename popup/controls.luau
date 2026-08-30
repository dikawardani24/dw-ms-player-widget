--!nonstrict
-- DW Music Player — popup controls.
--
-- Handles Previous, Play/Pause, Next button clicks.
-- Sends IPC commands to the Rust player backend.
-- Gracefully handles when the backend does not yet support these commands.

local ipc = require("../services.ipc")
local state = require("../services.state")

--- Send previous track command to the player.
-- Currently sends via the Unix socket IPC. The Rust player backend
-- must implement the "prev" command for this to have an effect.
-- If the backend does not support it, the command is sent but silently ignored.
local function on_previous()
  -- Protected call: do not let missing backend break the UI
  local ok, err = pcall(function()
    ipc.prev()
  end)
  if not ok then
    noctalia.log("Controls: previous command failed - " .. tostring(err))
  end
  -- Refresh state from cache after command
  state.refresh()
end

--- Send play/pause toggle command to the player.
-- Requires the Rust player to implement --play-pause CLI flag or
-- "play-pause" in the Unix socket command enum.
-- For now, this toggles window visibility via the existing --toggle command,
-- which is the documented fallback behavior.
local function on_play_pause()
  -- Protected call: do not let missing backend break the UI
  local ok, err = pcall(function()
    ipc.play_pause()
  end)
  if not ok then
    noctalia.log("Controls: play-pause command failed - " .. tostring(err))
  end
  -- Refresh state from cache after command
  state.refresh()
end

--- Send next track command to the player.
-- Currently sends via the Unix socket IPC. The Rust player backend
-- must implement the "next" command for this to have an effect.
-- If the backend does not support it, the command is sent but silently ignored.
local function on_next()
  -- Protected call: do not let missing backend break the UI
  local ok, err = pcall(function()
    ipc.next()
  end)
  if not ok then
    noctalia.log("Controls: next command failed - " .. tostring(err))
  end
  -- Refresh state from cache after command
  state.refresh()
end

return {
  on_previous = on_previous,
  on_play_pause = on_play_pause,
  on_next = on_next,
}