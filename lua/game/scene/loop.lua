-- relative to current scene
local loop     = {}
local lk       = love.keyboard
local settings = require "lua.default.settings"
local game     = require "lua.default.game"
local tools    = require "lua.tools"
function loop.game(...)
    local arg = { ... }
    local ply, dt = arg[1], arg[#arg]
    if not game.isPaused and not game.isPauseDelay then
        if not game.isCountdown then
            ply:update(dt)
            if lk.isDown(settings.keys.left) and not lk.isDown(settings.keys.right) then
                ply:shiftBlk(-1, dt)
            end
            if lk.isDown(settings.keys.right) and not lk.isDown(settings.keys.left) then
                ply:shiftBlk(1, dt)
            end
            if lk.isDown(settings.keys.sdrop) then
                ply:drop(dt)
            end
        end
        game.gfade, game.ginv = tools.invPulse(game.gfade, game.ginv, 1, 0.65, dt)
        if game.palp > 0 then
            game.palp = game.palp - dt * 16
        end
    else
        if game.palp < 1 then
            game.palp = game.palp + dt * 16
        end
        game.ptimer = game.ptimer + dt
    end
end

return loop
