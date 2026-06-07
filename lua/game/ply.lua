local ply = {}
local tables = require "lua.game.tables"
ply.__index = ply

--- returns framestep-like value with dt
---@param fps number
---@param mult number
---@return number
local function frameStep(fps, mult)
    return fps * (fps * mult) / fps
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
---@param sdr number -- piece drop rate
---@param ldly number -- lock delay
---@param lndly number -- line delay
---@param ndisp number -- next display count
---@param mReset number -- move reset limit
---@return table
function ply.new(initX, initY, brdX, brdY, w, h, das, dcd, arr, sdr, ldly, lndly, ndisp, mReset)
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
        cBlk = 0,
        next = {},
        ndisp = ndisp,
        hold = 0,
        rot = 1,
        d = 1, -- 1: ccw, 2: cw
        -- handling
        das = das,
        dcd = dcd,
        arr = arr,
        sdr = sdr,
        ldly = ldly,
        lndly = lndly,
        mReset = mReset,
        -- timers
        dasTimer = 0,
        dcdTimer = 0,
        ldlyTimer = 0,
        lndlytmr = 0,
        mRCount = 0,
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
        score = 0,
        lv = 0,
        gQueue = {},  -- garbage queue
        clrYPos = {}, -- for line effect & particles, lndly
        sGCheck = {}  -- bottom rows fill check for sg.
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

---returns the player board size
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

return ply
