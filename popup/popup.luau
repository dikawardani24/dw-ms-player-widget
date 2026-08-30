--!nonstrict
-- DW Music Player — popup panel (Noctalia panel entry).
--
-- Toggles visibility on bar click. Shows player controls, visualizer,
-- playlist, and current track info. Does not control playback; only
-- toggles the player window visibility.
--
-- Behavior:
--   bar click       ↓ toggle Noctalia popup panel
--   popup open      ↓ shows player UI
--   popup close     ↓ hides player UI (player window stays as-is)
--   player hidden   ↓ audio playback continues unchanged

local state = require("services.state")
local ipc = require("services.ipc")
local controls = require("popup.controls")
local playlist_mt = require("popup.playlist")
local animations = require("popup.animations")

-- Track whether the popup is currently open
local _popup_open = false

-- Lifecycle: called when the panel opens (from bar click)
function onOpen(context)
  _popup_open = true
  state.init()
  state.refresh()
  -- Read player visibility from cache after init
  -- This is distinct from popup state; it tracks the player window
end

-- Lifecycle: called when the panel closes
function onClose()
  _popup_open = false
end

-- Render the visualizer bars with fixed container height
local function render_visualizer()
  return animations.render_container()
end

-- Render the popup panel body
local function render_body()
  -- Read current player state from the service layer
  local visible = state.is_window_visible()
  local is_playing = state.is_playing()
  local title = state.get_title()
  local artist = state.get_artist()
  local duration = state.get_duration()
  local position = state.get_position()

  -- Ensure we have valid state
  if not title or title == "" then
    title = "🎵 Music Player"
  end

  -- UI: album artwork box
  local artwork_element
  if state.get_artwork() and state.get_artwork() ~= "" then
    artwork_element = ui.image({ path = state.get_artwork(), width = 128, height = 128, fit = "contain" })
  else
    artwork_element = ui.box({
      width = 128,
      height = 128,
      fill = "surface/0.8",
      radius = 8,
      child = ui.glyph({ name = "music", size = 48, color = "on_surface_variant" }),
    })
  end

  -- UI: visualizer - fixed height container, bars animate inside
  local visualizer = render_visualizer()

  -- UI: progress/time display
  local progress
  if duration > 0 then
    progress = ui.row({
      width = "100%",
    }, {
      ui.label({ text = string.format("%02d:%02d", math.floor(position / 60), position % 60), fontSize = 9, color = "on_surface_variant" }),
      ui.glyph({ name = "skip-next", size = 12, color = "primary" }),
      ui.label({ text = string.format("%02d:%02d", math.floor(duration / 60), duration % 60), fontSize = 9, color = "on_surface_variant" }),
    })
  else
    progress = ui.label({ text = "00:00", fontSize = 9, color = "on_surface_variant" })
  end

  -- UI: controls row (Previous, Play/Pause, Next)
  local controls_row = ui.row({ gap = 4, align = "center" }, {
    -- Previous button
    ui.button({
      glyph = "skip-previous",
      size = 20,
      variant = "ghost",
      tooltip = "Previous track",
      onClick = function()
        controls.on_previous()
        render()
      end,
    }),
    -- Play/Pause button
    ui.button({
      glyph = is_playing and "pause" or "play_arrow",
      size = 24,
      variant = "primary",
      tooltip = is_playing and "Pause" or "Play",
      onClick = function()
        controls.on_play_pause()
        render()
      end,
    }),
    -- Next button
    ui.button({
      glyph = "skip-next",
      size = 20,
      variant = "ghost",
      tooltip = "Next track",
      onClick = function()
        controls.on_next()
        render()
      end,
    }),
  })

  -- UI: playlist section (expandable/collapsible)
  local pl_header = playlist_mt.render_header()
  local pl_expanded = false
  local function toggle_playlist()
    pl_expanded = not pl_expanded
    render()
  end
  pl_header.onClick = toggle_playlist

  local pl_content = ui.column({ gap = 2, maxHeight = 0 }, {})
  if pl_expanded then
    pl_content = ui.column({ gap = 2 }, playlist_mt.render_items())
  end

  -- Build the panel body
  local body = ui.column({ gap = 8, flexGrow = 1 }, {
    -- Header row: artwork + title/artist
    ui.row({ gap = 8, align = "center" }, {
      artwork_element,
      ui.column({ gap = 4, flexGrow = 1 }, {
        ui.label({ text = title, fontSize = 14, fontWeight = "bold", color = "on_surface" }),
        ui.label({ text = artist, fontSize = 11, color = "on_surface_variant" }),
      }),
    }),
    -- Visualizer (fixed height)
    ui.row({ gap = 8, align = "center" }, {
      ui.box({
        height = animations.get_fixed_height(),
        fill = "surface/0.6",
        radius = 6,
        child = visualizer,
      }),
    }),
    -- Progress/time
    progress,
    -- Controls
    controls_row,
    -- Playlist toggle + content
    ui.column({ gap = 4 }, {
      pl_header,
      pl_content,
    }),
  })

  return body
end

-- Main render function
function render()
  if not _popup_open then return end

  local body = render_body()
  panel.render(body)
end

-- Update function - called on tick/periodically
function update()
  -- Poll state from cache and IPC
  state.refresh()
  -- Render the panel with updated state
  render()
end

-- Bar click handler: toggle the popup panel and the player window
function onClick()
  -- Toggle the Noctalia popup panel
  noctalia.togglePanel("dikawardani24/music-player:popup")
end

-- Bar right-click: show menu or do nothing extra
function onRightClick()
  noctalia.log("DW Music Player: right click on bar")
end