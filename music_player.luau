--!nonstrict
-- Fresh Noctalia bar widget for the standalone Music Player.
--
-- The widget deliberately owns no playback state. Its only responsibility is
-- to request a window toggle from the external player process.
--
-- This keeps these states independent:
--   bar widget visibility
--   music-player window visibility
--   audio playback state
--
-- Hiding the player must never pause or stop playback.

local glyph = noctalia.getConfig("glyph")
local command = noctalia.getConfig("command")

local function render()
  barWidget.setGlyph(glyph)
  barWidget.setTooltip("Music Player")
end

function update()
  noctalia.setUpdateInterval(60000)
  render()
end

function onClick()
  if command == nil or command == "" then
    noctalia.notify("Music Player", "No toggle command configured")
    return
  end

  -- The command must toggle only the player UI. It must not pause/stop audio.
  noctalia.runAsync(command)
end

function onIpc(event, payload)
  if event == "toggle" then
    if command ~= nil and command ~= "" then
      noctalia.runAsync(command)
    end
  elseif event == "refresh" then
    render()
  end
end
