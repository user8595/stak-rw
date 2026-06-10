local ply      = {}
ply.__index    = ply

local settings = require "lua.default.settings"
local gCol     = require "lua.gCol"
local states   = require "lua.game.states"
local tables   = require "lua.game.tables"
local gfx      = require "lua.game.gfx"
local lg       = love.graphics

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
        cblk = 1,
        brot = 1,
        hold = 0,
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
        -- options
        useghost = ghost,
        gravinc = true,
        -- states
        isfail = false,
        -- for per-level handling
        handleidx = 1,
        grav = 0,       -- 0 - 20+
        spinReward = 0, -- 0: none, 1: mini, 2: normal
        alreadyHold = false,
        alreadyRot = false,
        pieces = 0,
        finesse = 0,
        time = 0,
        lines = 0,
        ltarget = 10,
        mtarget = 100,
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
        mlv = 0,
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
    local cB = (self.cblk > 0) and tables.str[self.cblk] or "none"
    return self.cblk, cB
end

---adjusts player board position
---@param x integer
---@param y integer
function ply:setBrdPos(x, y)
    self.brdX, self.brdY = x, y
end

function ply:initPos()
    local w, _ = self:getBoardSize()
    self.x, self.y = math.floor(w / 2 - 2), 0
    self.brot = 1
end

function ply:clrBrd()
    for y = 1, #self.brd do
        for x = 1, #self.brd[y] do
            self.brd[y][x] = 0
        end
    end
end

function ply:move(d)
    local blk = tables.blk[self.rotsys][self.cblk][self.brot]
    self.dastimer = 0
    if states.bMove(blk, self.brd, self.x + d, self.y) then
        self.x = self.x + d
    end
end

function ply:rot(r)
    if self.brot + r <= #tables.blk[self.rotsys][self.cblk] and self.brot + r > 0 then
        self.brot = self.brot + r
    else
        self.brot = (r == 1) and 1 or #tables.blk[self.rotsys][self.cblk]
    end
end

function ply:shiftBlk(d, dt)
    local blk = tables.blk[self.rotsys][self.cblk][self.brot]
    if self.dastimer < self.das then
        self.dastimer = self.dastimer + dt
    else
        self.x = states.lowestShift(blk, self.brd, self.x, self.y, d)
    end
end

function ply:drop()
    --TODO: Make block table a single value on player object?
    local blk = tables.blk[self.rotsys][self.cblk][self.brot]
    if states.bMove(blk, self.brd, self.x, self.y + 1) and self.sdf > 0 then
        self.y = self.y + 1
    end
end

function ply:dropRepeat()
    local blk = tables.blk[self.rotsys][self.cblk][self.brot]
    if states.bMove(blk, self.brd, self.x, self.y + 1) and self.sdf > 0 then
        self.y = self.y + 1
    else
        self.y = states.lowestCells(blk, self.brd, self.x, self.y)
    end
end

function ply:hDrop()
    local blk = tables.blk[self.rotsys][self.cblk][self.brot]
    local lowesty = states.lowestCells(blk, self.brd, self.x, self.y)
    states.bAdd(blk, self.brd, self.x, lowesty)
    self.alreadyHold = false
    self:initPos()
end

function ply:holdfunc()
    if not self.alreadyHold then
        if self.hold ~= 0 then
            self.hold, self.cblk = self.cblk, self.hold
        else
            self.hold = self.cblk
        end
        self:initPos()
        self.alreadyHold = true
    end
end

---draws player board
function ply:drawBrd(blkW, blkH)
    local bwd, bhg = self:getBoardSize()
    local c = gCol[settings.colorscheme]
    lg.push()
    lg.translate(self.brdX + ((blkW * bwd) / 2), self.brdY + ((blkH * bhg) / 2))
    lg.scale(settings.scale, settings.scale)
    lg.rotate(self.sRval)
    lg.translate((-(blkW * bwd) / 2), -(blkH * bhg) / 2)

    gfx.dpersp(self.brd, blkW, blkH, tables.col[self.rotsys])
    for y = 1, #self.brd do
        for x = 1, #self.brd[y] do
            local blk = self.brd[y][x]
            local col = c[tables.col[self.rotsys][blk]]
            gfx.dgrid(x, y, 0, bhg)
            if blk ~= 0 then
                gfx.dblocks(blk, x, y, blkW, blkH, 1, col)
            end
        end
    end

    lg.setLineWidth(1)
    lg.setLineWidth(1.5)
    lg.setColor(c.white)
    lg.rectangle("line", 0, 0, bwd * blkW, bhg * blkH)
    lg.setLineWidth(1)

    if self.cblk > 0 and self.cblk <= #tables.blk[self.rotsys] then
        local blocks = tables.blk[self.rotsys][self.cblk][self.brot]
        local lowesty = states.lowestCells(blocks, self.brd, self.x, self.y)
        lg.push()
        lg.translate(blkW * self.x, blkH * self.y)
        gfx.dpersp(blocks, blkW, blkH, tables.col[self.rotsys])
        lg.pop()
        for y = 1, #blocks do
            for x = 1, #blocks[y] do
                local blk = blocks[y][x]
                local col = c[tables.col[self.rotsys][blk]]
                gfx.dghost(blk, self.x + x, lowesty + y, blkW, blkH,
                    (settings.ghostcolors) and col or gCol[settings.colorscheme].white)
                gfx.dblocks(blk, self.x + x, self.y + y, blkW, blkH, (self.endly - self.endlytimer) / self.endly, col)
            end
        end
    end
    lg.pop()
end

return ply
