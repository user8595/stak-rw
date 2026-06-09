local settings = require "lua.default.settings"
local ply = {}
ply.__index = ply

local tables = require "lua.game.tables"
local gfx = require "lua.game.gfx"
local lg = love.graphics

--- returns framestep-like value with dt
---@param fps number
---@param mult number
---@return number
local function frameStep(fps, mult)
    return fps * (fps * mult) / fps
end

---checks for permissive block movement
---@param blk table -- current block table
---@param mtrx table -- board table
---@param x integer -- current block x
---@param y integer -- current block y
local function bMove(blk, mtrx, x, y)
    if blk then
        for my = 1, #blk do
            for mx = 1, #blk[my] do
                if blk[my][mx] ~= 0 then
                    local tx, ty = x + mx, math.floor(y + my)
                    if tx < 1 or tx > #mtrx[my] or ty > #mtrx then
                        return false
                    else
                        if ty > 0 then
                            if mtrx[ty][tx] ~= 0 then
                                return false
                            end
                        end
                    end
                end
            end
        end
    else
        return false
    end
    return true
end

---adds blocks to board table
---@param blk table
---@param mtrx table
---@param x integer
---@param y integer
local function bAdd(blk, mtrx, x, y)
    if blk then
        for my = 1, #blk do
            for mx = 1, #blk[my] do
                local b = blk[my][mx]
                if y + my > 0 then
                    if b ~= 0 then
                        mtrx[math.floor(y + my)][x + mx] = b
                    end
                end
            end
        end
    end
end

---returns the lowest y position for the current block
---@param blk table
---@param mtrx table
---@param x integer
---@param y integer
---@return number
local function lowestCells(blk, mtrx, x, y)
    local ty = (y >= 0) and math.floor(y) or 0
    for _ = 1, #mtrx do
        if bMove(blk, mtrx, x, ty + 1) then
            ty = ty + 1
        else
            break
        end
    end
    return ty
end

---creates new player object
---@param initX number -- initial x postion
---@param initY number -- initial y position
---@param brdX number -- board x position
---@param brdY number -- board y position
---@param w number -- board width
---@param h number -- board height
---@param das number -- shift delay
---@param dcd number -- delay before shift delay
---@param arr number -- shift rate
---@param sdf number -- piece drop rate
---@param ldly number -- lock delay
---@param endly number -- entry delay (are)
---@param lndly number -- line delay
---@param ndisp number -- next display count
---@param rotsys string -- rotation system
---@param bagtype string -- randomizer type
---@param mReset number -- move reset limit
---@param ghost boolean -- show piece placement preview
---@return table
function ply.new(initX, initY, brdX, brdY, w, h, das, dcd, arr, sdf, ldly, endly, lndly, ndisp, rotsys, bagtype, mReset,
                 ghost)
    local p = {
        -- piece positions
        x = 0,
        y = 0,
        initX = initX,
        initY = initY,
        -- board position
        brdX = brdX,
        brdY = brdY,
        brd = {},
        next = {},
        ndisp = ndisp,
        cBlk = 1,
        hold = 0,
        brot = 1,
        d = 1, -- 1: ccw, 2: cw
        rotsys = rotsys,
        bagtype = bagtype,
        -- handling
        das = das,
        dcd = dcd,
        arr = arr,
        sdf = sdf,
        ldly = ldly,
        endly = endly,
        lndly = lndly,
        mReset = mReset,
        -- timers
        dastimer = 0,
        dcdtimer = 0,
        ldlytimer = 0,
        endlytimer = 0,
        lndlytimer = 0,
        mRCount = 0,
        -- activators
        isdcd = false,
        isldly = false,
        islndly = false,
        isirs = false,
        isihs = false,
        useghost = ghost,
        -- for per-level handling
        handleidx = 1,
        grav = 0,       -- 0 - 20+
        spinReward = 0, -- 0: none, 1: mini, 2: full
        alreadyHold = false,
        alreadyRot = false,
        pieces = 0,
        finesse = 0,
        time = 0,
        lines = 0,
        sts = {
            sg = 0,
            db = 0,
            trp = 0,
            qd = 0,
            ac = 0,
            spin = {
                sg = 0,
                db = 0,
                trp = 0
            }
        },
        comb = 0,
        strk = 0,
        sentLines = 0,
        score = 0,
        lv = 0,
        gQueue = {},  -- garbage queue
        clrYPos = {}, -- for line effect & particles, lndly
        sGCheck = {}, -- bottom rows fill check for sg.
        sGIdx = 1,
        lineEfct = {},
        lockEfct = {},
        lPart = {},
        --TODO: Improve shake handling?
        sX = false,
        sY = false,
        sR = false,
        sXinv = false,
        sYinv = false,
        sRinv = false,
        sXval = 0,
        sYval = 0,
        sRval = 0
    }
    p.x, p.y = initX, initY
    for hg = 1, h do
        p.brd[#p.brd + 1] = {}
        for wd = 1, w do
            p.brd[hg][wd] = 0
        end
    end

    for _ = 1, 20 do
        p.sGCheck[#p.sGCheck + 1] = true
    end

    return setmetatable(p, ply)
end

---returns the player's board size
---@return integer
---@return integer
function ply:getBoardSize()
    local w, h = 0, 0
    for hg = 1, #self.brd do
        h = hg
        for wd = 1, #self.brd[hg] do
            w = wd
        end
    end
    return w, h
end

---returns player position
---@param floor boolean | nil
---@param isInverse boolean | nil
---@return integer
---@return integer
function ply:getPos(floor, isInverse)
    local yP = (isInverse) and #self.brd - self.y or self.y
    local x, y = (floor) and math.floor(self.x) or self.x, (floor) and math.floor(yP) or yP
    return x, y
end

---returns current block
---@return integer
---@return string
function ply:getBlk()
    local cB = (self.cBlk > 0) and tables.str[self.cBlk] or "none"
    return self.cBlk, cB
end

---draws player board
function ply:drawBrd(blkW, blkH)
    lg.push()
    lg.translate(self.brdX, self.brdY)
    local bwd, bhg = self:getBoardSize()
    lg.rectangle("line", 0, 0, bwd * blkW, bhg * blkH)

    for y = 1, #self.brd do
        for x = 1, #self.brd[y] do
            local blk = self.brd[y][x]
            local col = tables.col[self.rotsys][blk]
            gfx.dgrid(x, y, 0)
            gfx.dblocks(blk, x, y, blkW, blkH, 1, col)
        end
    end

    local blocks = tables.blk[self.rotsys][self.cBlk][self.brot]
    if self.cBlk > 0 and self.cBlk <= #tables.blk[self.rotsys] then
        for y = 1, #blocks do
            for x = 1, #blocks[y] do
                local blk = blocks[y][x]
                local col = tables.col[self.rotsys][blk]
                gfx.dblocks(blk, self.x + x, self.y + y, blkW, blkH, (self.endly - self.endlytimer) / self.endly, col)
                if self.useghost then
                    local lowesty = lowestCells(blocks, self.brd, self.x, self.y) + y
                    if settings.ghosttype == 1 then
                        if blk ~= 0 then
                            lg.setLineWidth(1)
                            lg.setLineWidth(blkH / (blkH / 2))
                            lg.setColor(col[1], col[2], col[3], settings.ghostopacity)
                            lg.rectangle("line", blkW * (self.x + x - 1), blkH * (lowesty - 1), blkW, blkH)
                            lg.setLineWidth(1)
                        end
                    end
                    gfx.dblocks(blk, self.x + x, lowesty, blkW, blkH, settings.ghostopacity, col)
                end
            end
        end
    end
    lg.pop()
end

return ply
