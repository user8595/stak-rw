local rand = {}
local states = require "lua.game.states"
local tools = require "lua.tools"
local tables = require "lua.game.tables"
local bagdef = { 1, 2, 3, 4, 5, 6, 7 }

function rand.modern(t, init)
    if init then
        for _ = 1, (t.ndisp > 7) and math.ceil(t.ndisp / 7) or 1 do
            local sh = states.shuffle(bagdef)
            t.next = tools.concatTab(t.next, sh)
        end
    else
        if #t.next < ((t.ndisp > 0) and t.ndisp or 1) then
            local sh = states.shuffle(bagdef)
            t.next = tools.concatTab(t.next, sh)
        end
    end
end

function rand.master(t, init)
    if init then
    else
    end
end

function rand.master35(t, init)
    if init then
    else
    end
end

function rand.classic(t, init)
    if init then
    else
    end
end

function rand.rand(t, init)
    if init then
        for _ = 1, t.ndisp do
            t.next[#t.next + 1] = love.math.random(1, #tables.blk[t.rotsys])
        end
    else
        t.next[#t.next + 1] = love.math.random(1, #tables.blk[t.rotsys])
    end
end

return rand
