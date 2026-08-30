--!nonstrict
-- DW Music Player — popup controls.

local ipc = require("ipc")
local state = require("state")

function controls.on_previous()
  ipc.prev()
  state.refresh()
end

function controls.on_play_pause()
  ipc.play_pause()
  state.refresh()
end

function controls.on_next()
  ipc.next()
  state.refresh()
end

return { on_previous, on_play_pause, on_next }