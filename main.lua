-- ################################################################
-- ## only for learning purposes, no rewrite is planned for stak ##
-- ################################################################

local settings = require("lua.default.settings")
local fonts = require("lua.default.fonts")
local ply = require("lua.game.ply").new((settings.boardW / 2) - 2, 0, 20, 20, settings.boardW, settings.boardH,
    settings.das, settings.dcd, settings.arr, settings.sdf, settings.ldly, settings.endly, settings.lnDly, settings
    .ndisp, settings.rotsys, settings.bagtype, settings.movereset, (settings.ghosttype > 0) and true or false)
local debug = require("lua.debug")
local lg, lk, lw = love.graphics, love.keyboard, love.window

function love.load()
    if arg[2] == "debug" then
        settings.isDebug = true
    end
    lg.setDefaultFilter("nearest", "nearest")
end

function love.keypressed(k)
    if k == "escape" then
        love.event.quit(0)
    end
    if k == "f4" then
        settings.isDebug = (not settings.isDebug) and true or false
    end
    if k == "f11" or lk.isDown("lalt", "ralt") and k == "return" then
        lw.setFullscreen((not lw.getFullscreen()) and true or false)
    end
end

function love.mousereleased(x, y, b, istouch)

end

function love.update(dt)

end

function love.draw()
    lg.setColor(1, 1, 1, 1)
    ply:drawBrd(settings.blkW, settings.blkH)

    if settings.isDebug then
        debug.gameinfo(ply)
    end

    lg.setColor(1, 1, 1, 0.5)
    lg.print("v0.1dev", fonts.othr, 10, lg.getHeight() - 25)
end
