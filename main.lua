-- ################################################################
-- ## only for learning purposes, no rewrite is planned for stak ##
-- ################################################################

local lg, lk, lw = love.graphics, love.keyboard, love.window
local settings   = require("lua.default.settings")
local fonts      = require("lua.default.fonts")
local debug      = require("lua.debug")
local loop       = require("lua.game.loop")
local game       = require("lua.default.game")

local ply        = require("lua.game.ply").new((settings.boardW / 2) - 2, 0, 0, 0, settings.boardW, settings.boardH,
    settings.das, settings.dcd, settings.arr, settings.sdf, settings.ldly, settings.endly, settings.lnDly, settings
    .ndisp, settings.rotsys, settings.bagtype, settings.movereset, (settings.ghosttype > 0) and true or false)

function love.load()
    local bwd, bhg = ply:getBoardSize()
    ply:setBrdPos((lg.getWidth() / 2) - ((settings.blkW * bwd) / 2), (lg.getHeight() / 2) - ((settings.blkH * bhg) / 2))
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
    if k == "0" then
        settings.scale = lg.getHeight() / 720
    end
    if k == "e" then
        ply:clrBrd()
    end

    if k == settings.keys.left then
        ply:move(-1)
    end
    if k == settings.keys.right then
        ply:move(1)
    end
    if k == settings.keys.sdrop then
        ply:drop()
    end
    if k == settings.keys.hold then
        ply:holdfunc()
    end
    if k == settings.keys.cw then
        ply:rot(1)
    end
    if k == settings.keys.ccw then
        ply:rot(-1)
    end
    if k == settings.keys.hdrop then
        ply:hDrop()
    end
end

function love.mousereleased(x, y, b, istouch)

end

function love.resize(w, h)
    local bwd, bhg = ply:getBoardSize()
    settings.scale = h / 720
    ply:setBrdPos((w / 2) - ((settings.blkW * bwd) / 2), (h / 2) - ((settings.blkH * bhg) / 2))
end

function love.update(dt)
    loop.game(ply, dt)

    if lk.isDown("=") then
        settings.scale = settings.scale + dt
    end
    if lk.isDown("-") then
        settings.scale = settings.scale - dt
    end
end

function love.draw()
    lg.setColor(1, 1, 1, 1)
    ply:drawBrd(settings.blkW, settings.blkH)

    if settings.isDebug then
        debug.gameinfo(ply)
    end
    lg.setColor(1, 1, 1, 0.25)
    lg.print("v0.1dev ", fonts.othr, 10, lg.getHeight() - 25)
end
