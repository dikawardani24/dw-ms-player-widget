--!nonstrict
-- DW Music Player — visualizer animation.
--
-- Fixed-height container with animated bars.
-- Bars animate inside the container; the container itself never grows.
-- Since the Noctalia Music Player Rust binary does not expose FFT/audio level data
-- via the Unix socket IPC, this module provides a safe fallback animation
-- using random bar height variations within the fixed container.
--
-- Design constraint: visualizer container height is constant.
-- Only the bar heights vary inside it.

local M = {}

-- Animation state for visualizer bars
local _bar_heights = { 8, 6, 10, 7, 9, 5 }
local _animation_phase = 0

-- Tick the visualizer animation.
-- Called from the popup's update loop.
-- This simulates bar animation without real audio data.
function M.tick()
  _animation_phase = (_animation_phase + 1) % 60

  -- Update bar heights with pseudo-random but bounded variation
  -- Each bar's height varies between 4 and 12 within the fixed container
  for i = 1, #_bar_heights do
    -- Simple sine-based oscillation for deterministic-looking animation
    local phase_offset = (i * 17 + _animation_phase) % 60
    local base_height = 8
    local variation = math.sin(phase_offset * math.pi / 30) * 2
    _bar_heights[i] = math.max(4, math.min(12, base_height + variation))
  end
end

-- Render the visualizer bars inside a fixed-height container.
-- The container has a constant height; only the bar heights change.
-- @param container_height the fixed height of the visualizer container
-- @return ui.element a column containing the animated bars
function M.render_container()
  -- Re-tick the animation on each render
  M.tick()

  -- Build bar elements with current heights
  local bars = {}
  for i, height in ipairs(_bar_heights) do
    -- Clamp height to be within reasonable bounds for the container
    local clamped = math.max(2, math.min(16, height))
    table.insert(bars, ui.box({
      width = 4,
      height = clamped,
      fill = "primary",
      radius = 2,
    }))
  end

  -- Fixed-height container: always 32px tall
  -- Bars animate inside it; container height never changes
  return ui.column({ height = 32 }, bars)
end

-- Get the fixed visualizer container height in pixels.
-- This value should not change regardless of animation state.
function M.get_fixed_height()
  return 32
end

return M