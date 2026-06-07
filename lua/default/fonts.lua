local fonts = {
    main = love.graphics.newFont("/assets/fonts/monogram-extended.TTF", 28),
    othr = love.graphics.newFont("/assets/fonts/Picopixel.ttf", 14)
}

for _, v in pairs(fonts) do
    v:setFilter("nearest", "nearest")
end

return fonts