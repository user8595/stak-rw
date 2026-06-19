local ply      = {}

local settings = require "lua.default.settings"
local gCol     = require "lua.gCol"
local states   = require "lua.game.states"
local rotsys   = require "lua.game.rotsys"
local tables   = require "lua.game.tables"
local rand     = require "lua.game.rand"
local gfx      = require "lua.game.gfx"
local game     = require "lua.default.game"
local lerp     = require "lua.lerp"
local tools    = require "lua.tools"
local lg       = love.graphics

---creates new player object
---@param initX number -- initial x postion
---@param initY number -- initial y position
---@param brdX number -- board x position
---@param brdY number -- board y position
---@param w number -- board width
---@param h number -- board height
---@param hmult boolean -- multiply board height
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
---@param useghost boolean -- show piece placement preview
---@return table
function ply:new(initX, initY, brdX, brdY, w, h, hmult, das, dcd, arr, sdf, ldly, endly, lndly, ndisp, rotsys, bagtype,
                 mReset, useghost)
    local p = {
        -- piece positions
        x = 0,
        y = 0,
        initX = initX,
        initY = (hmult) and initY + h or initY,
        -- board position
        brdX = brdX,
        brdY = brdY,
        brd = {},
        next = {},
        ndisp = ndisp,
        cblk = 0,
        cbmtrx = {},
        brot = 1,
        hold = 0,
        d = 1, -- 1: ccw, 2: cw
        lastkick = 0,
        rotsys = rotsys,
        bagtype = bagtype,
        hmult = hmult,
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
        useghost = useghost,
        gravinc = true,
        invis = false,
        mode = 1, -- 1: normal, 2: vs
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
        -- side bar meter values
        val = 0,
        max = 100,
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
    p.x, p.y = p.initX, p.initY
    local hs = (hmult) and h * 2 or h
    for hg = 1, hs do
        p.brd[#p.brd + 1] = {}
        for wd = 1, w do
            p.brd[hg][wd] = 0
        end
    end

    rand[p.bagtype](p, true)

    for _ = 1, 20 do
        p.sGCheck[#p.sGCheck + 1] = true
    end

    self.__index = self
    return setmetatable(p, self)
end

---returns the player's board size
---@return integer
---@return integer
function ply:getBoardSize()
    return #self.brd[#self.brd], (self.hmult) and #self.brd / 2 or #self.brd
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
---@return number
---@return string
---@return number
function ply:getBlk()
    local cB = (self.cblk > 0) and tables.str[self.cblk] or "none"
    return self.cblk, cB, self.hold
end

---adjusts player board position
---@param x integer
---@param y integer
function ply:setBrdPos(x, y)
    self.brdX, self.brdY = x, y
end

---adjusts player settings via string
---@param str string
---@param val any
function ply:settings(str, val)
    for k, _ in pairs(self) do
        if k == str then
            self[str] = val
            break
        end
    end
end

function ply:initPos()
    self.x, self.y = self.initX, self.initY
    self.brot = 1
end

function ply:initPiece()
    if self.cblk == 0 then
        if self.next[1] then
            self.cblk = self.next[1]
        end
        table.remove(self.next, 1)
        if #self.next < self.ndisp then
            rand[self.bagtype](self, false)
        end
    end
    self.cblks = tables.blk[self.rotsys][self.cblk]
end

function ply:setblk(id)
    if id > 0 and id <= #tables.blk[self.rotsys] then
        self.cblks = tables.blk[self.rotsys][id]
    end
end

function ply:clrBrd()
    for y = 1, #self.brd do
        for x = 1, #self.brd[y] do
            self.brd[y][x] = 0
        end
    end
end

function ply:setTarget(val, max)
    self.val, self.max = val, max
end

function ply:addRows(x, w, h, str)
    local wd, hg = self:getBoardSize()

    for _ = 1, h do
        self.brd[#self.brd + 1] = {}
        for xw = 1, wd do
            if xw >= x and xw < x + w then
                self.brd[#self.brd][xw] = 0
            else
                self.brd[#self.brd][xw] = str
            end
        end
        table.remove(self.brd, 1)
    end

    for _ = 1, hg * 2 do
        if not states.bMove(self.cblks[self.brot], self.brd, self.x, self.y) then
            self.y = self.y - 1
        else
            break
        end
    end
end

function ply:getDanger(hOff)
    local w, _ = self:getBoardSize()
    local dgY = 8 + hOff
    for y = 1, #self.brd do
        for x = 1, w do
            if x > math.floor(w / 8) and x < w - math.floor(w / 8) then
                if y < dgY and y > dgY - 2 then
                    if self.brd[y][x] ~= 0 then
                        return 1
                    end
                elseif y < dgY - 2 then
                    if self.brd[y][x] ~= 0 then
                        return 2
                    end
                end
            end
        end
    end
    return 0
end

function ply:getFail()
    if not states.bMove(self.cblks[self.brot], self.brd, self.x, self.y) then
        return true
    end
    return false
end

---adds blocks to board table
---@param blk table
---@param mtrx table
---@param x integer
---@param y integer
function ply:bAdd(blk, mtrx, x, y)
    if blk then
        for my = 1, #blk do
            for mx = 1, #blk[my] do
                local b = blk[my][mx]
                if b ~= 0 then
                    if y + my > 0 and y + my <= #mtrx then
                        mtrx[math.floor(y + my)][math.floor(x + mx)] = b
                    end
                end
            end
        end
    end

    for y = 1, #mtrx do
        local clr = true
        for x = 1, #mtrx do
            if mtrx[y][x] == 0 then
                clr = false
                break
            end
        end
        if clr then
            for x = 1, #mtrx[y] do
                for ydel = y, 2, -1 do
                    mtrx[ydel][x] = mtrx[ydel - 1][x]
                end
                mtrx[1][x] = 0
            end
            self.lines = self.lines + 1
        end
    end
end

function ply:move(d)
    self.dastimer = 0
    if states.bMove(self.cblks[self.brot], self.brd, self.x + d, self.y) then
        self.x = self.x + d
    end
end

function ply:rot(d)
    local tr = (self.brot + d <= 0) and #self.cblks or (self.brot + d > #self.cblks) and 1 or self.brot + d

    if d == 2 then
        if self.brot == 1 then
            tr = (#self.cblks > 2) and 3 or 1
        elseif self.brot == 2 then
            tr = (#self.cblks > 2) and 4 or 1
        elseif self.brot == 3 then
            tr = 1
        elseif self.brot == 4 then
            tr = 2
        end
    end
    self.d = (d >= 1) and 2 or 1

    local isrot, x, y, kick = rotsys[self.rotsys](self.cblks, self.brd, self.x, self.y, (d >= 2) and true or false, tr, self.d, self.cblk)
    if isrot then
        self.x, self.y, self.brot, self.lastkick = x, y, tr, kick
    end
end

function ply:shiftBlk(d, dt)
    if self.cblks then
        if self.dastimer < self.das - dt then
            self.dastimer = self.dastimer + dt
        else
            local lowestX = states.lowestShift(self.cblks[self.brot], self.brd, self.x, self.y, d)
            if self.arr > 0 then
                -- thats complex
                local shft = (self.arr > 1) and 1 or (1 - self.arr) + 1
                local frames = (self.arr > 1) and settings.framestep / self.arr or settings.framestep * (2 - self.arr)
                local sUpd = dt * states.frameStep(frames, shft)
                if d == 1 then
                    if lowestX - self.x >= sUpd then
                        self.x = self.x + sUpd
                    else
                        self.x = lowestX
                    end
                elseif d == -1 then
                    if self.x - lowestX >= sUpd then
                        self.x = self.x - sUpd
                    else
                        self.x = lowestX
                    end
                end
            else
                self.x = lowestX
            end
        end
    end
end

function ply:drop(dt)
    --TODO: Make block table a single value on player object?
    if self.cblks then
        local lowestY = states.lowestCells(self.cblks[self.brot], self.brd, self.x, self.y)
        if self.sdf > 0 then
            local gUpd = dt * states.frameStep(settings.framestep, self.sdf)
            if lowestY - self.y >= gUpd then
                self.y = self.y + gUpd
            else
                self.y = lowestY
            end
        else
            self.y = lowestY
        end
    end
end

function ply:lock()
    self:bAdd(self.cblks[self.brot], self.brd, self.x, self.y)
    self.alreadyHold = false
    self:initPos()
    if self.next then
        if self.next[1] then
            self.cblk = self.next[1]
        end
        table.remove(self.next, 1)
        rand[self.bagtype](self, false)
    end
    self:setblk(self.cblk)
    self:setTarget(self.lines, settings.target)
end

function ply:hDrop()
    self.y = states.lowestCells(self.cblks[self.brot], self.brd, self.x, self.y)
    self:lock()
    self.isfail = self:getFail()
end

function ply:holdfunc()
    if not self.alreadyHold then
        if self.hold ~= 0 then
            local ctemp = self.cblk
            self.cblk = self.hold
            self.hold = ctemp
            self:setblk(self.cblk)
        else
            self.hold = self.cblk
            if self.next then
                self.cblk = self.next[1]
                table.remove(self.next, 1)
                self:setblk(self.cblk)
            end
        end
        rand[self.bagtype](self)
        self:initPos()
        self.alreadyHold = true
    end
end

function ply:key(k)
    if self.cblks then
        if k == settings.keys.left then
            self:move(-1)
        end
        if k == settings.keys.right then
            self:move(1)
        end
        if k == settings.keys.cw then
            self:rot(1)
        end
        if k == settings.keys.ccw then
            self:rot(-1)
        end
        if k == settings.keys.flip then
            self:rot(2)
        end
        if k == settings.keys.hdrop then
            self:hDrop()
        end
    end
    if k == settings.keys.hold then
        self:holdfunc()
    end
end

---uodates player object
---@param dt integer
function ply:update(dt)

end

---draws side meter
function ply:drwMtr(col, coloutline, x, w, h, garb, val, max)
    local _, bhg = self:getBoardSize()
    if val and max and not garb then
        local t = (val / max < 1) and val / max or 1
        lg.setColor(col)
        lg.rectangle("fill", x, h * #self.brd, w / 2.5, -((h * bhg) * t))
        if coloutline then
            lg.setColor(coloutline)
        end
        lg.setLineWidth(1)
        lg.setLineWidth(1.5 * (h / 32))
        lg.rectangle("line", x, h * #self.brd, w / 2.5, -(h * bhg))
        lg.setLineWidth(1)
    elseif garb then
        --TODO: Implement garbage meter
    end
end

---draws target line
function ply:drwTrgtLn(w, h, val, max, c, cnear)
    local wd, hg = self:getBoardSize()
    local col

    if val >= max - hg and val < max then
        if c and cnear then
            col = (val < max - 10) and c or cnear
            lg.setColor(col)
        else
            lg.setColor(gCol[settings.colorscheme].white)
        end
        local y = (max - (val - hg)) - hg
        lg.push()
        if self.hmult then
            lg.translate(0, h * hg)
        end
        lg.line(0, h * (hg - y), w * wd, h * (hg - y))
        lg.pop()
    end
end

local tex = lg.newImage("/assets/img/blocks/bone.png")
tex:setFilter("nearest", "nearest")
---draws player board
function ply:drawBrd(blkW, blkH)
    local bwd, bhg = self:getBoardSize()
    local c = gCol[settings.colorscheme]
    lg.push()
    lg.translate(self.brdX + ((blkW * bwd) / 2), self.brdY + ((blkH * bhg) / 2))
    lg.scale(settings.scale, settings.scale)
    lg.rotate(self.sRval)
    lg.translate((-(blkW * bwd) / 2), -(blkH * bhg) / 2)
    lg.push()
    lg.translate(0, (self.hmult) and -(blkH * bhg) or 0)
    gfx.dpersp(self.brd, blkW, blkH, tables.col[self.rotsys], (self.isfail) and "gray" or nil)

    for y = 1, #self.brd do
        for x = 1, #self.brd[y] do
            local blk = self.brd[y][x]
            local col = (not self.isfail) and c[tables.col[self.rotsys][blk]] or c.gray
            local grdy = (not self.hmult) and y > 0 or y > bhg
            if grdy then
                gfx.dgrid(x, y, 0, bhg, self.hmult)
            end
            if blk ~= 0 then
                gfx.dblocks(blk, x, y, blkW, blkH, 1, col, tex)
            end
        end
    end

    lg.setLineWidth(1)
    lg.setLineWidth(1.5 * (blkH / 32))
    self:drwTrgtLn(blkW, blkH, self.val, self.max, c.yellow, c.green)
    lg.setLineWidth(1)

    -- local sc = 1.075
    local sc = 1.12
    local hn = (self.hmult) and blkH or 0
    lg.push()
    lg.translate(blkW * (bwd + 1), hn * (sc + .175))
    self:drawQueue(self.next, blkW / sc, blkH / sc, self.ndisp)
    lg.pop()
    lg.push()
    lg.translate((-blkW) * 5, hn * (sc + .175))
    self:drawQueue(self.hold, blkW / sc, blkH / sc, 1)
    lg.pop()

    if self.cblk > 0 and self.cblk <= #tables.blk[self.rotsys] then
        local blocks = self.cblks[self.brot]
        local lowesty = states.lowestCells(blocks, self.brd, self.x, self.y)
        local py = (settings.smoothfall) and self.y or math.floor(self.y)
        lg.push()
        lg.translate(blkW * math.floor(self.x), blkH * py)
        gfx.dpersp(blocks, blkW, blkH, tables.col[self.rotsys], (self.isfail) and "gray" or nil)
        lg.pop()
        for y = 1, #blocks do
            for x = 1, #blocks[y] do
                local blk = blocks[y][x]
                local col = (not self.isfail) and c[tables.col[self.rotsys][blk]] or c.gray
                if blk ~= 0 then
                    if self.useghost then
                        gfx.dghost(blk, math.floor(self.x) + x, lowesty + y, blkW, blkH,
                            lerp.linear(settings.ghostopacity, settings.ghostopacity / 1.2, game.gfade),
                            (settings.ghostcolors) and col or gCol[settings.colorscheme].white, tex)
                    end
                    gfx.dblocks(blk, math.floor(self.x) + x, py + y, blkW, blkH,
                        (self.endly - self.endlytimer) / self.endly, col,
                        tex)
                end
            end
        end
    end

    if self.mode == 1 then
        self:drwMtr(gCol[settings.colorscheme].orange, c.white, blkW * bwd, settings.blkW, settings.blkH, nil, self
            .val, self.max)
    elseif self.mode == 2 then
        self:drwMtr(gCol[settings.colorscheme].red, c.white, -blkW / 2.5, settings.blkW, settings.blkH, self.gQueue)
    end

    lg.setColor(1, 1, 1, 1)
    lg.print(
        self:getDanger(bhg) ..
        " " ..
        #self.next ..
        " " ..
        self.brot .. ", " .. self.d .. "(" .. self.lastkick .. ")" .. " " .. self.val .. "/" .. self.max .. " " .. tostring(self.isfail) .. " " .. self
        .dastimer, 0,
        blkH * bhg)
    lg.pop()
    lg.setLineWidth(1)
    lg.setLineWidth(1.5 * (blkH / 32))
    lg.setColor(c.white)
    lg.rectangle("line", 0, 0, bwd * blkW, bhg * blkH)
    lg.setLineWidth(1)
    lg.pop()
end

---draws current queue from number/table
function ply:drawQueue(cblk, w, h, count)
    local ctr = {
        ars = {
            { 0,  .5 },
            { .5, 0 },
            { .5, 0 },
            { 0,  0 },
            { .5, 0 },
            { .5, 0 },
            { .5, 0 },
        },
        srs = {
            { 0,  .5 },
            { .5, 1 },
            { .5, 1 },
            { 0,  1 },
            { .5, 1 },
            { .5, 1 },
            { .5, 1 },
        },
        nrs = {
            { 0,  -.5 },
            { .5, 0 },
            { .5, 0 },
            { 0,  0 },
            { .5, 0 },
            { .5, 0 },
            { .5, 0 },
        }
    }
    local function q(cb)
        local c = gCol[settings.colorscheme]
        local blk = tables.blk[self.rotsys][cb]
        if cb and cb > 0 and cb <= #tables.blk[self.rotsys] then
            for y = 1, #blk[1] do
                for x = 1, #blk[1][y] do
                    if blk[1][y][x] ~= 0 then
                        local col = (not self.isfail) and c[tables.col[self.rotsys][blk[1][y][x]]] or
                            c.gray
                        local _, hg = self:getBoardSize()
                        local yh = (self.hmult) and y + hg or y

                        gfx.dblocks(blk[1][y][x], x, yh, w, h, 1, col, tex)
                    end
                end
            end
        end
    end
    if type(cblk) == "table" then
        if cblk then
            for ndisp = 1, count do
                local cx, cy =
                    (cblk[ndisp] and cblk[ndisp] ~= 0) and ctr[self.rotsys][cblk[ndisp]][1] or 0,
                    (cblk[ndisp] and cblk[ndisp] ~= 0) and ctr[self.rotsys][cblk[ndisp]][2] or 0
                lg.push()
                -- imagine 10pc 40l with this
                -- "messy"
                local l = 6
                local spc = 2.65
                local shftx = (ndisp / l > 1) and math.ceil(ndisp / l) or 1
                lg.translate(w * cx + (w * (4 * (shftx - 1))), (((h * (spc)) * (ndisp - 1)) + (h * cy)))
                if ndisp > l then
                    lg.translate(0, -((h * (spc)) * (l * (math.ceil(ndisp / l) - 1))))
                end
                q(cblk[ndisp])
                -- lg.print(cx .. ", " .. cy .. shftx, 0, h * (#self.brd / 2))
                lg.pop()
            end
        end
    else
        local cx, cy =
            (cblk and cblk > 0) and ctr[self.rotsys][cblk][1] or 0,
            (cblk and cblk > 0) and ctr[self.rotsys][cblk][2] or 0
        lg.push()
        lg.translate(w * cx, h * cy)
        q(cblk)
        lg.pop()
    end
end

return ply
