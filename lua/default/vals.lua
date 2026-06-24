local vals = {}
local settings = require "lua.default.settings"
local lg = love.graphics

function vals.newply(invis)
    local ply = require("lua.game.ply"):new((settings.boardW / 2) - 2, -2, 0, 0, settings.boardW,
    settings.boardH, settings.hmult, settings.das, settings.dcd, settings.arr, settings.sdf, settings.ldly,
    settings.endly,
    settings.lnDly, settings.ndisp, settings.rotsys, settings.bagtype, settings.movereset,
    (settings.ghosttype > 0) and true or false)
    local bwd, bhg = ply:getBoardSize()
    ply:setBrdPos((lg.getWidth() / 2) - ((settings.blkW * bwd) / 2), (lg.getHeight() / 2) - ((settings.blkH * bhg) / 2))
    ply:settings("invis", invis)
    return ply
end

return vals
