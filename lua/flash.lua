local flash = {}
flash.__index = flash
---creates new color flash object
---@param cols table -- colors to cycle in flash, structure: {{1, 0, 1}, {1, 0, 0}, ..}
---@param spd integer -- cycle speed
---@param t integer -- timer limit before increment
---@return table
function flash.newFlash(cols, spd, t)
    local fl = {
        cols = cols,
        idx = 1,
        timer = 0,
        spd = spd,
        t = t,
    }
    return setmetatable(fl, flash)
end

---updates color flash object
---@param dt integer
function flash:updateFlash(dt)
    if self.timer < self.t then
        self.timer = self.timer + dt * self.spd
    else
        if self.idx + 1 <= #self.cols then
            self.idx = self.idx + 1
        else
            self.idx = 1
        end
        self.timer = self.timer - self.t
    end
end

---sets color from color flash object
function flash:setColor()
    love.graphics.setColor(self.cols[self.idx])
end

return flash