local debug = {}
local fonts = require "lua.default.fonts"
local lg, lt = love.graphics, love.timer

---draws player stats & other info
---@param ply table
function debug.gameinfo(ply)
    local x, y = ply:getPos()
    local cb, cbstr = ply:getBlk()
    local ltxt
    local rtxt = string.format("x: %g\ny: %g\ncBlk: %g/%s", x, y, cb, cbstr)
    
    if arg[2] == "debug" then
        ltxt = string.format("%g FPS / %gs dt\n%gx%g", lt.getFPS(), lt.getDelta(), lg.getWidth(), lg.getHeight())
        lg.printf(rtxt, fonts.othr, 0, 10, lg.getWidth() - 10, "right")
    else
        ltxt = string.format("%g FPS\n%gx%g", lt.getFPS(), lg.getWidth(), lg.getHeight())
    end
    lg.printf(ltxt, fonts.othr, 10, 10, lg.getWidth(), "left")
end

return debug
