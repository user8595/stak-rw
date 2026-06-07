local settings = {
    colorscheme = "catppuccin_mocha", -- "catppuccin_mocha", "gruvbox"
    blTheme = "", -- empty string ("") / nil for colorscheme
    scale = 1,
    isDebug = false,
    keys = {
        left = "a",
        right = "d",
        hdrop = "w",
        sdrop = "s",
        ccw = "k",
        cw = "l",
        flip = "j",
        hold = "space",
        pause = "p",
        restart = "`",
    },
    boardW = 10,
    boardH = 20,
    rotsys = "srs", -- "srs", "ars", "nrs"
    bagtype = "modern", -- "modern", "master", "classic", "rand"
    das = 100 / 1000,
    dcd = 0 / 1000,
    arr = 6 / 1000,
    sdr = 0 / 1000,
    ldly = 500 / 1000,
    ndisp = 5, -- next display count
    movereset = 15
}

return settings