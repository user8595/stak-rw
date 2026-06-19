local fonts = require "lua.default.fonts"
--TODO: Use tables for scenes, not functions (?)
local scenes = {}
local lg = love.graphics

function scenes.game(...)
    local arg      = { ... }

    local ply      = arg[1]
    local game     = require "lua.default.game"
    local settings = require "lua.default.settings"
    lg.setColor(1, 1, 1, 1)
    ply:drawBrd(settings.blkW, settings.blkH)

    lg.setColor(0, 0, 0, 0.25 * (game.palp / 1))
    lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())
    lg.push()
    lg.translate(0, (-fonts.main:getHeight() / 2) + lg.getHeight() / 2)
    lg.setColor(.5, .5, .5, .45 * (game.palp / 1))
    lg.printf("PAUSED", fonts.main, 3,  3, lg.getWidth(), "center")
    lg.setColor(1, 1, 1, 1 * (game.palp / 1))
    lg.printf("PAUSED", fonts.main, 0, 0, lg.getWidth(), "center")
    lg.printf("<P> to continue", fonts.othr, 0, 40, lg.getWidth(), "center")
    --TODO: Add ticker text stats on bottom & reveal ticker text feature
    lg.pop()
end

return scenes
