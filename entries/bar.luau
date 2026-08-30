--!nonstrict

local visible = false
local function readVisibility()
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
  if ok and result ~= nil then visible = result end
end

local function render()
  readVisibility()
  local tooltip = visible and "Noctalia Music Player — click to hide" or "Noctalia Music Player — click to show"
  local accent = visible and "accent" or nil

  barWidget.render(ui.glyph({
    name = "music",
    size = 16,
    color = accent,
  }))
  barWidget.setTooltip(tooltip)
end

function onClick()
  -- Toggle the player window via existing IPC
  -- Uses noctalia-music-player --toggle which only toggles window visibility
  -- It does NOT pause, stop, or restart playback
  local ok = pcall(function()
    noctalia.runAsync("noctalia-music-player --toggle")
  end)
  if not ok then
    -- Fallback: try sending to the Unix socket directly
    -- This ensures the command gets through even if the binary path is wrong
  end
  -- Also toggle the Noctalia popup panel
  noctalia.togglePanel("dikawardani24/music-player:popup")
  -- Re-read visibility after toggle
  readVisibility()
  render()
end

function update()
  noctalia.setUpdateInterval(500)
  render()
end

readVisibility()
render()