-- this already feels nostalgic
-- even though it's been only 3-4 months since i worked on the previous game..

-- ############################################################
-- # as usual, this game relies a LOT with 1-based indexing.. #
-- ############################################################
-- and clouds are white

local lg, lk, lw = love.graphics, love.keyboard, love.window
local tick       = require("libs.tick")
local settings   = require("lua.default.settings")
local fonts      = require("lua.default.fonts")
local debug      = require("lua.debug")
local game       = require("lua.default.game")
local loop       = require("lua.game.scene.loop")
local scenes     = require("lua.game.scene.scenes")
local func       = require("lua.default.func")

local ply        = func.newply(settings.invis)

function love.load()
    if arg[2] == "debug" then
        settings.isDebug = true
    end

    -- the culmination of your soul
    tick.rate = 1 / settings.framestep

    lg.setDefaultFilter("nearest", "nearest")
    ply:initPiece()
    love.window.setVSync(1)
    -- for y = 1, #ply.brd do
    --     for x = 1, #ply.brd[y] do
    --         if x < y then
    --             ply.brd[y][x] = "Z"
    --         end
    --     end
    -- end
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
        if not game.isPaused then
            game.pcount = game.pcount + 1
        end
        game.isPaused = (not game.isPaused) and true or false
    end

    if not game.isPaused and not game.isPauseDelay then
        ply:key(k)
        if k == "escape" then
            if not game.isPaused then
                game.pcount = game.pcount + 1
            end
            game.isPaused = true
            -- a replay system
            -- using tables as lists of frame events
            -- must be fixed at 60 frames
            -- so maybe aftery 1/60ths of a second, add the current action to the replay list?
            -- use another variable for the game settings
            -- rest (board state, next queue, ply state (except for stats, handle that by the game itself?)) put in the frame events table
            -- and you need a framestep limiter (?)
            -- or not
        end
        -- is this safe for the gc
        if k == "`" then
            ply = func.newply(settings.invis)
            ply:initPiece()
            game.pcount = 0
            game.ptimer = 0
        end
    else
        if k == "escape" then
            love.event.quit(0)
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
