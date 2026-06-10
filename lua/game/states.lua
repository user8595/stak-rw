local states = {}

--- returns framestep-like value with dt
---@param fps number
---@param mult number
---@return number
function states.frameStep(fps, mult)
    return fps * (fps * mult) / fps
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
function states.bAdd(blk, mtrx, x, y)
    if blk then
        for my = 1, #blk do
            for mx = 1, #blk[my] do
                local b = blk[my][mx]
                if y + my > 0 and y + my <= #mtrx then
                    if b ~= 0 then
                        mtrx[math.floor(y + my)][x + mx] = b
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
        end
    end
end

---returns the lowest y position for the current block
---@param blk table
---@param mtrx table
---@param x integer
---@param y integer
---@return number
function states.lowestCells(blk, mtrx, x, y)
    local ty = (y >= 0) and math.floor(y) or 0
    for _ = 1, #mtrx do
        if states.bMove(blk, mtrx, x, ty + 1) then
            ty = ty + 1
        else
            break
        end
    end
    return ty
end

function states.lowestShift(blk, mtrx, x, y, d)
    local y = (y > 0) and y or 1
    local tx = x
    for _ = 1, #mtrx[y] do
        if states.bMove(blk, mtrx, tx + d, y) then
            tx = tx + d
        else
            break
        end
    end
    return tx
end

return states
