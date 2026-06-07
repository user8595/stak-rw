local settings = require("lua.default.settings")
local debug = require("lua.debug")
local ply = require("lua.game.ply").new(
    (settings.boardW / 2) - 2, 0, 0, 0, settings.boardW, settings.boardH, settings.das,
    settings.dcd, settings.arr, settings.sdr, settings.ldly, settings.lnDly, settings.ndisp, settings.movereset)
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
    local w, h = ply:getBoardSize()
    for y = 1, h do
        for x = 1, w do
            lg.rectangle("line", 20 + (20 * (x - 1)), 20 + (20 * (y - 1)), 20, 20)
        end
    end

    if settings.isDebug then
        debug.gameinfo(ply)
    end
end
