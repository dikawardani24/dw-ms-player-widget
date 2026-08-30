--!nonstrict
-- DW Music Player — popup panel (Noctalia panel entry).

local state = require("state")
local ipc = require("ipc")
local controls = require("popup.controls")

local _popup_open = false

function onOpen(context)
  _popup_open = true
  state.init()
  state.refresh()
end

function onClose()
  _popup_open = false
end

function render()
  if not _popup_open then return end

  local visible = state.is_window_visible()
  local is_playing = state.is_playing()
  local title = state.get_title()
  local artist = state.get_artist()
  local duration = state.get_duration()
  local position = state.get_position()

  if not title or title == "" then title = "🎵 Music Player" end

  -- Artwork
  local artwork_element
  if state.get_artwork() and state.get_artwork() ~= "" then
    artwork_element = ui.image({ path = state.get_artwork(), width = 128, height = 128, fit = "contain" })
  else
    artwork_element = ui.box({
      width = 128, height = 128,
      fill = "surface/0.8", radius = 8,
      child = ui.glyph({ name = "music", size = 48, color = "on_surface_variant" }),
    })
  end

  -- Visualizer
  local visualizer = ui.column({ height = 32 }, {
    ui.box({ width = 4, height = 8, fill = "primary" }),
    ui.box({ width = 4, height = 6, fill = "primary/0.7" }),
    ui.box({ width = 4, height = 10, fill = "primary/0.8" }),
    ui.box({ width = 4, height = 7, fill = "primary/0.6" }),
    ui.box({ width = 4, height = 9, fill = "primary/0.9" }),
    ui.box({ width = 4, height = 5, fill = "primary" }),
  })

  -- Progress
  local progress
  if duration > 0 then
    progress = ui.row({ width = "100%" }, {
      ui.label({ text = string.format("%02d:%02d", math.floor(position/60), position%60), fontSize = 9, color = "on_surface_variant" }),
      ui.glyph({ name = "skip-next", size = 12, color = "primary" }),
      ui.label({ text = string.format("%02d:%02d", math.floor(duration/60), duration%60), fontSize = 9, color = "on_surface_variant" }),
    })
  else
    progress = ui.label({ text = "00:00", fontSize = 9, color = "on_surface_variant" })
  end

  -- Controls
  local controls_row = ui.row({ gap = 4, align = "center" }, {
    ui.button({ glyph = "skip-previous", size = 20, variant = "ghost", tooltip = "Previous", onClick = function() controls.on_previous() end }),
    ui.button({ glyph = is_playing and "pause" or "play_arrow", size = 24, variant = "primary", tooltip = is_playing and "Pause" or "Play", onClick = function() controls.on_play_pause() end }),
    ui.button({ glyph = "skip-next", size = 20, variant = "ghost", tooltip = "Next", onClick = function() controls.on_next() end }),
  })

  -- Simple body
  local body = ui.column({ gap = 8, flexGrow = 1 }, {
    ui.row({ gap = 8, align = "center" }, {
      artwork_element,
      ui.column({ gap = 4, flexGrow = 1 }, {
        ui.label({ text = title, fontSize = 14, fontWeight = "bold", color = "on_surface" }),
        ui.label({ text = artist, fontSize = 11, color = "on_surface_variant" }),
      }),
    }),
    ui.row({ gap = 8, align = "center" }, { visualizer }),
    progress,
    controls_row,
  })

  panel.render(body)
end

function onClick()
  noctalia.togglePanel("dikawardani24/music-player:popup")
end

function onRightClick()
  noctalia.log("DW Music Player: right click")
end