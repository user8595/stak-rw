---@format disable
local settings = {
    -- visual settings
    colorscheme = "catppuccin_mocha", -- "catppuccin_mocha", "gruvbox"
    blkTheme = "", -- empty string ("") / nil for colorscheme
    gridopacity = 0.5, -- ex. 0, 0.5, 1
    gridtype = 1, -- 1: corner dots, 2: grid, 3: checkerboard
    ghostopacity = 0.5,
    ghosttype = 1, -- 0: none, 1: bordered, 2: solid, 3: block image
    locktype = 1, -- 0: none, 1: solid, 2: triangular, 3: "reveal" effect
    hdropeffect = true,
    lineeffects = true,
    scale = 1,

    -- keybinds
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

    -- player settings
    boardW = 10,
    boardH = 20,
    blkW = 32,
    blkH = 32,
    rotsys = "srs",     -- "srs", "ars", "nrs"
    bagtype = "modern", -- "modern", "master", "classic", "rand"
    das = 100 / 1000,
    dcd = 0 / 1000,
    arr = 6 / 1000,
    sdf = 0 / 1000,
    ldly = 500 / 1000,
    endly = 250 / 1000,
    lndly = 250 / 1000,
    ndisp = 5, -- next display count
    movereset = 15,
    useirs = false,
    useihs = false,

    isDebug = false,
}

return settings
