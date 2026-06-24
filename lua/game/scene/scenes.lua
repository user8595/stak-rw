local fonts  = require "lua.default.fonts"
local gCol   = require "lua.gCol"
--TODO: Use tables for scenes, not functions (?)
local scenes = {}
local lg     = love.graphics
local fail   = fonts.beeg
fail:setLineHeight(0.8)

function scenes.game(...)
    local arg      = { ... }
    local ply      = arg[1]
    local game     = require "lua.default.game"
    local settings = require "lua.default.settings"
    local c        = gCol[settings.colorscheme]

    --TODO: Improve background  graphics
    lg.setColor(c.bg)
    lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())

    lg.setColor(1, 1, 1, 1)
    ply:drawBrd(settings.blkW, settings.blkH)

    if ply.isfail then
        lg.push()
        lg.translate(0, (lg.getHeight() / 2) - fail:getHeight())
        lg.setColor(c.red[1] - .4, c.red[2] - .4, c.red[3] - .4, 1)
        lg.printf("GAME\nOVER", fail, 3, 3, lg.getWidth(), "center")
        lg.setColor(gCol[settings.colorscheme].red)
        lg.printf("GAME\nOVER", fail, 0, 0, lg.getWidth(), "center")
        lg.setColor(1, 1, 1, 0.5)
        lg.printf({c.gray, "<`> to restart game"}, fonts.othr, 2, ((fail:getHeight() * 2) - (fonts.othr:getHeight() / 2)) + 2, lg.getWidth(), "center")
        lg.setColor(1, 1, 1, 1)
        lg.printf({c.orange, "<`>", c.white, " to restart game"}, fonts.othr, 0, (fail:getHeight() * 2) - (fonts.othr:getHeight() / 2), lg.getWidth(), "center")
        lg.pop()
    end

    lg.setColor(0, 0, 0, 0.25 * (game.palp / 1))
    lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())
    lg.push()
    lg.translate(0, (-fonts.main:getHeight() / 2) + lg.getHeight() / 2)
    lg.setColor(.5, .5, .5, .45 * (game.palp / 1))
    lg.printf("PAUSED", fonts.main, 3, 3, lg.getWidth(), "center")
    lg.setColor(1, 1, 1, 1 * (game.palp / 1))
    lg.printf("PAUSED", fonts.main, 0, 0, lg.getWidth(), "center")
    lg.printf("<P> to continue", fonts.othr, 0, 40, lg.getWidth(), "center")
    lg.printf({ c.orange, "[#" .. game.pcount .. "] ", { 1, 1, 1, .5 }, string.format("%.2fs", game.ptimer) }, fonts
    .othr, 0, 60, lg.getWidth(), "center")
    --TODO: Add ticker text stats on bottom & reveal ticker text feature
    lg.pop()
end

return scenes
