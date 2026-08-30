--!nonstrict

-- Fresh Noctalia bar widget for the standalone Music Player.
-- The widget only asks the player to toggle its window.
-- It never controls playback state.

local function render()
    barWidget.render(ui.button({
        glyph = "music",
        glyphSize = 16,
        variant = "ghost",
        width = 28,
        height = 28,
        tooltip = "Music Player",
        onClick = "togglePlayer",
    }))
end

function togglePlayer()
    noctalia.runAsync({ "noctalia-music-playerctl", "toggle" })
end

function update()
    noctalia.setUpdateInterval(60000)
    render()
end

render()
