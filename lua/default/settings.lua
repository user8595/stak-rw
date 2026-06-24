local settings = {
    -- visual settings
    colorscheme = "catppuccin_mocha", -- "catppuccin_mocha", "gruvbox"
    blkTheme = "",                    -- empty string ("") / nil for colorscheme
    gridopacity = 0.35,               -- ex. 0, 0.5, 1
    gridtype = 1,                     -- 1: corner dots, 2: grid, 3: checkerboard
    ghostopacity = 0.5,
    ghostcolors = true,
    ghosttype = 4,      -- 0: none, 1: bordered, 2: solid, 3: outline, 4: block image theme
    locktype = 1,       -- 0: none, 1: solid, 2: triangular, 3: "reveal" effect
    lineeffecttype = 1, -- 0: none, 1: "spread" effect, 2: flash w. scale
    lefctldly = false,  -- if line effect should use line delay timer
    hdropeffect = true,
    perspEfct = true,   -- show 3d effect in blocks
    outlineEfct = true, -- show outline borders effect
    smoothfall = true,
    --TODO: Implement rotation centers
    showrotcenter = false,
    target = 80,
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
    blkW = 30,
    blkH = 30,
    rotsys = "srs",     -- "srs", "ars", "nrs"
    bagtype = "modern", -- "modern", "master", "master35", "classic", "rand"
    das = 85 / 1000,
    dcd = 0 / 1000,
    arr = 0,      -- in frames
    sdf = 0 / 10, -- 0 for instant drop
    ldly = 500 / 1000,
    endly = 250 / 1000,
    lndly = 250 / 1000,
    ndisp = 125, -- next display count
    movereset = 15,
    useirs = false,
    useihs = false,
    hmult = true,
    invis = false,

    isDebug = false,
    framestep = 60
}

return settings
