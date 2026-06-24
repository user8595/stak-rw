local gfx      = {}
local gCol     = require "lua.gCol"
local lerp     = require "lua.lerp"
local settings = require "lua.default.settings"
local lg       = love.graphics

---draws blocks from table
---@param blk string | number
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param a integer -- set to 1 if solid
---@param col table -- block color
---@param tex love.Image | nil -- block texture
---@param quad  love.Quad | nil
-- divide quad area with image height?
function gfx.dblocks(blk, x, y, w, h, a, col, tex, quad)
    if tex then
        if quad then
            local _, _, qw, qh = quad:getViewport()
            lg.draw(tex, quad, w * (x - 1), h * (y - 1), 0, w / qw, h / qh)
        else
            local iw, ih = tex:getDimensions()
            lg.setColor(col[1], col[2], col[3], a)
            lg.draw(tex, w * (x - 1), h * (y - 1), 0, w / iw, h / ih)
        end
    else
        if blk ~= 0 then
            lg.setColor(col[1], col[2], col[3], a)
            lg.rectangle("fill", w * (x - 1), h * (y - 1), w, h)
        end
    end
end

--TODO: Implement stencil clipping in outlines, conditional checks (?) & perspective effect support
function gfx.doutline(persp, mtrx, w, h, col, a)
    local woff, hoff = -w / 12, -h / 12
    local p = (persp) and h / 8 or 0
    for y = 1, #mtrx do
        for x = 1, #mtrx[y] do
            local blk = mtrx[y][x]
            if blk ~= 0 then
                lg.setColor(col[1], col[2], col[3], a)
                lg.push()
                lg.translate(woff, hoff - p)
                -- i forgot basic aritmetic
                lg.rectangle("fill", w * (x - 1), h * (y - 1), w - (woff * 2), (h + p) - (hoff * 2))
                lg.pop()
            end
        end
    end
end

---draws blocks for perspective effect
---@param mtrx table
---@param w integer
---@param h integer
---@param a integer
---@param colstrlist table
---@param stroverride string | nil -- for block color
function gfx.dpersp(mtrx, w, h, a, colstrlist, stroverride)
    for y = 1, #mtrx do
        for x = 1, #mtrx[y] do
            local blk = mtrx[y][x]
            if blk ~= 0 then
                local str = (stroverride) and stroverride or colstrlist[blk]
                local col = gCol[settings.colorscheme][str]
                local cDark = { col[1] - .2, col[2] - .2, col[3] - .2 }
                lg.push()
                lg.translate(0, -(h / 8))
                gfx.dblocks(blk, x, y, w, h, a, cDark)
                lg.pop()
            end
        end
    end
end

---draws grid background
---@param x integer
---@param y integer
---@param ylimit integer
---@param brdH integer
---@param hmult boolean
function gfx.dgrid(x, y, ylimit, brdH, hmult)
    local w, h = settings.blkW, settings.blkH

    if y > ylimit then
        if settings.gridtype > 0 then
            local c = gCol[settings.colorscheme].gray
            lg.setColor(c[1], c[2], c[3],
                lerp.linear(settings.gridopacity, settings.gridopacity / 1.35, (y - ((hmult) and brdH or 0)) / brdH))
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

---draws preview piece
---@param blk string | number
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param a integer
---@param col table
---@param tex love.Image
---@param quad love.Quad | nil
function gfx.dghost(blk, x, y, w, h, a, col, tex, quad)
    if blk ~= 0 then
        lg.setColor(col[1], col[2], col[3], a)
        if settings.ghosttype == 1 or settings.ghosttype == 3 then
            lg.setLineWidth(1)
            lg.setLineWidth((settings.ghosttype == 1) and h / (h / 2) or 1 + (h / h * 2))
            lg.rectangle("line", w * (x - 1), h * (y - 1), w, h)
            lg.setLineWidth(1)
        end
    end

    if settings.ghosttype ~= 3 then
        gfx.dblocks(blk, x, y, w, h, a, col, (settings.ghosttype == 4) and (tex) and tex or nil,
            (quad) and quad or nil)
    end
end

return gfx
