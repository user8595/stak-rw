-- wall kicks
local rotsys = {}
local states = require "lua.game.states"
local tables = require "lua.game.tables"

function rotsys.ars(blk, mtrx, x, y, _, r, _, cblk)
    if cblk ~= 1 or cblk ~= 4 then
        if not states.bMove(blk[r], mtrx, x, y) then
            if states.bMove(blk[r], mtrx, x + 1, y) then
                return true, x + 1, y, 1
            end
            if states.bMove(blk[r], mtrx, x - 1, y) then
                return true, x - 1, y, 1
            end
        end
    end
    if not states.bMove(blk[r], mtrx, x, y) then
        return false, x, y, 0
    end
    return true, x, y, 1
end

-- might be useful then
function rotsys.srs(blk, mtrx, x, y, flip, r, d, cblk)
    local tb = tables.kick.srs
    local kick = (cblk ~= 4) and (cblk ~= 1) and tb[1][d][r] or tb[2][d][r] or tb[4][r]
    if flip and not cblk ~= 4 then
        kick = tb[3][r]
    end
    for i = 1, #kick do
        if kick[i][1] and kick[i][2] then
            local tx, ty = kick[i][1], kick[i][2]
            if states.bMove(blk[r], mtrx, x + tx, y - ty) then
                return true, x + tx, y - ty, i
            end
        end
    end
    return false, x, y, 0
end

function rotsys.nrs(blk, mtrx, x, y, _, r, _, cblk)
    if states.bMove(blk[r], mtrx, x, y) then
        return true, x, y, 1
    end
    return false, x, y, 0
end

return rotsys
