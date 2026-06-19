-- game loop checks
local states = {}

--- returns framestep-like value with dt
---@param fps number
---@param mult number
---@return number
function states.frameStep(fps, mult)
    return fps * (fps * mult) / fps
end

---shuffle & returns shuffled table
---@param t any
---@return table
function states.shuffle(t)
    local s = {}
    for i = 1, #t do s[i] = t[i] end
    for i = #t, 2, -1 do
        local j = love.math.random(i)
        s[i], s[j] = s[j], s[i]
    end
    return s
end

---checks for permissive block movement
---@param blk table -- current block table
---@param mtrx table -- board table
---@param x integer -- current block x
---@param y integer -- current block y
function states.bMove(blk, mtrx, x, y)
    if blk then
        for my = 1, #blk do
            for mx = 1, #blk[my] do
                if blk[my][mx] ~= 0 then
                    local tx, ty = math.floor(x + mx), math.floor(y + my)
                    if tx < 1 or tx > #mtrx[#mtrx] or ty > #mtrx then
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

---returns the lowest y position for the current block
---@param blk table
---@param mtrx table
---@param x integer
---@param y integer
---@return number
function states.lowestCells(blk, mtrx, x, y)
    local ty = y
    while states.bMove(blk, mtrx, x, ty + 1) and ty <= #mtrx do
        ty = ty + 1
    end
    return math.floor(ty)
end

function states.lowestShift(blk, mtrx, x, y, d)
    local tx, ty = math.floor(x), y
    for _ = 1, #mtrx[#mtrx] do
        if states.bMove(blk, mtrx, tx + d, ty) then
            tx = tx + d
        else
            break
        end
    end
    return tx, ty
end

return states
