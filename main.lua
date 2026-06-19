local lg, lk, lw = love.graphics, love.keyboard, love.window
local settings   = require("lua.default.settings")
local fonts      = require("lua.default.fonts")
local debug      = require("lua.debug")
local game       = require("lua.default.game")
local loop       = require("lua.game.scene.loop")
local scenes     = require("lua.game.scene.scenes")

local ply        = require("lua.game.ply"):new((settings.boardW / 2) - 2, -2, 0, 0, settings.boardW,
    settings.boardH, settings.hmult, settings.das, settings.dcd, settings.arr, settings.sdf, settings.ldly,
    settings.endly,
    settings.lnDly, settings.ndisp, settings.rotsys, settings.bagtype, settings.movereset,
    (settings.ghosttype > 0) and true or false)

function love.load()
    if arg[2] == "debug" then
        settings.isDebug = true
    end
    lg.setDefaultFilter("nearest", "nearest")
    local bwd, bhg = ply:getBoardSize()
    ply:setBrdPos((lg.getWidth() / 2) - ((settings.blkW * bwd) / 2), (lg.getHeight() / 2) - ((settings.blkH * bhg) / 2))
    ply:initPiece()

    love.window.setVSync(1)
end

---@param k love.KeyConstant
function love.keypressed(k)
    if k == "f4" then
        settings.isDebug = (not settings.isDebug) and true or false
    end
    if k == "f11" or lk.isDown("lalt", "ralt") and k == "return" then
        lw.setFullscreen((not lw.getFullscreen()) and true or false)
    end
    if k == "0" then
        settings.scale = lg.getHeight() / 720
    end

    if k == "p" then
        game.isPaused = (not game.isPaused) and true or false
    end

    if not game.isPaused and not game.isPauseDelay then
        ply:key(k)
        if k == "escape" then
            game.isPaused = true
        end
    else
        if k == "escape" then
            love.event.quit(0)
        end
    end

    if arg[2] == "debug" then
        if k == "e" then
            ply:clrBrd()
        end
        if k == "r" then
            ply:initPos()
        end

        if k == "backspace" then
            if not lk.isDown("lctrl", "rctrl") then
                ply:addRows(math.random(1, settings.boardW), 1, love.math.random(1, 4), "g")
            else
                ply:addRows(4, 4, 1, "g")
            end
        end
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
    loop[game.scene](ply, dt)

    -- if lk.isDown(settings.keys.hdrop) then
    --     ply:hDrop()
    --     ply:addRows(4, 4, love.math.random(2, 9), tables.str[love.math.random(1, #tables.str)])
    -- end
    if lk.isDown("=") then
        settings.scale = settings.scale + dt
    end
    if lk.isDown("-") then
        settings.scale = settings.scale - dt
    end
end

function love.draw()
    scenes[game.scene](ply)

    if settings.isDebug then
        debug.gameinfo(ply)
    end
    lg.setColor(1, 1, 1, 0.25)
    lg.print("v0.1dev", fonts.othr, 10, lg.getHeight() - 25)
end
