local gfx = {}
local gCol = require "lua.gCol"
local settings = require "lua.default.settings"
local tables = require "lua.game.tables"
local lg = love.graphics

---draws blocks from table
---@param blk string | number
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param a integer
---@param col table -- block color
---@param tex love.Image | nil -- tex. will be used as quad
-- divide quad area with image height?
function gfx.dblocks(blk, x, y, w, h, a, col, tex)
    if tex then

    else
        if blk ~= 0 then
            lg.setColor(col[1], col[2], col[3], a)
            lg.rectangle("fill", w * (x - 1), h * (y - 1), w, h)
        end
    end
end

function gfx.dgrid(x, y, ylimit)
    local w, h = settings.blkW, settings.blkH

    if y > ylimit then
        if settings.gridtype > 0 then
            local c = gCol[settings.colorscheme].gray
            lg.setColor(c[1], c[2], c[3], settings.gridopacity)
            if settings.gridtype == 1 then
                lg.rectangle("fill", w * (x - 1), h * (y - 1), w / 8, h / 8)
            elseif settings.gridtype == 2 then
                lg.rectangle("fill", (w * x) - w / 10, h * (y - 1), w / 10, h)
                lg.rectangle("fill", w * (x - 1), (h * y) - h / 10, w, h / 10)
            elseif settings.gridtype == 3 then
                lg.rectangle("fill", w * (x - 1) + (w / 10), h * (y - 1) + (w / 10), w - (w / 10), h - (h / 10))
            end
        end
    end
end

return gfx
