--!nonstrict
-- Unix socket IPC helper for Noctalia Music Player.
-- Sends plain-text commands to the Rust player's Unix socket.
-- Protocol: one line per command: "toggle", "show", "hide", "status", "play-pause", "next", "prev".

local _socket_path = "/run/user/1000/noctalia-music-player.sock"
local _fallback_socket = "/home/dika/.cache/noctalia-music-player.sock"

local function socket_path()
  if io.popen("test -S " .. _socket_path .. " 2>/dev/null && echo " .. _socket_path .. " || echo ''"):read("*l") == _socket_path then
    return _socket_path
  end
  return _fallback_socket
end

local function send_command(cmd)
  -- Protected: do not let socket errors crash the widget
  local ok, err = pcall(function()
    local f = io.popen("echo '" .. cmd .. "' | nc -U " .. socket_path() .. " 2>/dev/null")
    if f then
      f:close()
    end
  end)
  if not ok then
    noctalia.log("IPC: failed to send command: " .. tostring(err))
  end
end

--- Toggle the player window (show/hide). Does NOT affect playback.
function ipc.toggle()
  send_command("toggle")
end

--- Show the player window if hidden.
function ipc.show()
  send_command("show")
end

--- Hide the player window if visible.
function ipc.hide()
  send_command("hide")
end

--- Attempt to get player status from the Unix socket.
-- Currently not implemented in the player backend; returns nil.
function ipc.status()
  -- Player does not currently expose status via IPC socket
  return nil
end

--- Send a play/pause toggle command to the player.
function ipc.play_pause()
  send_command("play-pause")
end

--- Send next track command to the player.
function ipc.next()
  send_command("next")
end

--- Send previous track command to the player.
function ipc.prev()
  send_command("prev")
end

--- Read the current player visibility state from the cache file.
function ipc.get_visibility()
  local ok, result = pcall(function()
    local f = io.open("/home/dika/.cache/noctalia-music-player-visible", "r")
    if f then
      local v = f:read("*l")
      f:close()
      if v == "1" then return true end
      if v == "0" then return false end
    end
    return false
  end)
  if ok and result ~= nil then return result end
  return false
end

return ipc