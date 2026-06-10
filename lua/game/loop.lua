-- relative to current scene
local loop     = {}
local lk       = love.keyboard
local settings = require "lua.default.settings"
function loop.game(ply, dt)
    if lk.isDown(settings.keys.left) then
        ply:shiftBlk(-1, dt)
    end

    if lk.isDown(settings.keys.right) then
        ply:shiftBlk(1, dt)
    end
    if lk.isDown(settings.keys.sdrop) then
        ply:dropRepeat()
    end
end

return loop
