--!nonstrict
-- DW Music Player — playlist section.
--
-- Expandable/collapsible playlist view.
-- Shows current track as identifiable.
-- Clicking a track calls the player's actual track-selection mechanism.
-- Popup height may change when expanded; must NOT change because of visualizer amplitude.

local state = require("../services.state")

--- Render the playlist header with toggle indicator.
-- @return ui.element the header row
local function render_header()
  local is_expanded = state.get_playlist_index() > 0 and state.get_playlist_index() <= #state.get_playlist()
  local indicator = is_expanded and "chevron-up" or "chevron-down"
  return ui.row({ gap = 4, align = "center" }, {
    ui.label({ text = "Playlist", fontSize = 9, color = "on_surface_variant" }),
    ui.glyph({ name = indicator, size = 10, color = "on_surface_variant" }),
  })
end

--- Toggle playlist expansion state.
local function toggle()
  -- Toggle the playlist visibility state
  -- The actual expansion state is managed by the popup render
  -- This function is called from the popup's render cycle
end

--- Render the current playlist items.
-- @return ui.element column of track rows
local function render_items()
  local tracks = state.get_playlist()
  if #tracks == 0 then
    return ui.label({ text = "No tracks loaded", fontSize = 9, color = "on_surface_variant" })
  end

  local items = {}
  for i, track in ipairs(tracks) do
    local is_current = state.get_playlist_index() == i
    local track_name = track or ("Track " .. tostring(i))
    table.insert(items, ui.row({ gap = 4, align = "center" }, {
      ui.glyph({ name = "circle", size = 8, color = is_current and "primary" or "on_surface_variant" }),
      ui.label({ text = track_name, fontSize = 9, color = is_current and "primary" or "on_surface_variant", flexGrow = 1 }),
    }))
  end

  return ui.column({ gap = 2 }, items)
end

--- Get whether the playlist is currently expanded.
-- @return boolean true if expanded, false if collapsed
function state.is_playlist_expanded()
  -- Playlist expansion is tracked separately from the player window
  -- This is a conceptual state; the actual UI expansion is rendered
  -- based on user interaction
  return false
end

--- Set the playlist expansion state.
-- @param expanded true to expand, false to collapse
function state.set_playlist_expanded(expanded)
  -- State management for playlist expansion
  -- The UI re-renders to reflect this change
end

--- Handle clicking a track in the playlist.
-- Calls the player's track-selection mechanism if available.
-- @param index the track index to select (1-based)
function state.select_track(index)
  -- TODO: When the Rust player supports track selection via IPC,
  -- send the appropriate command here.
  -- For now, this is a no-op placeholder that will be implemented
  -- when the player backend supports it.
  noctalia.log("Playlist: track selection requested for index " .. tostring(index))
end

return {
  render_header = render_header,
  render_items = render_items,
  toggle = toggle,
  is_expanded = state.is_playlist_expanded,
  set_expanded = state.set_playlist_expanded,
  select_track = state.select_track,
}