-- Desktop:
hl.monitor({
    output = "DP-4",
    mode = "2560x1440@144",
    position = "1440x0",
    scale = 1,
})
hl.monitor({
    output = "DP-5",
    mode = "2560x1440@144",
    position = "0x-415",
    scale = 1,
    transform = 1,
})

-- Laptop:
hl.monitor({
    output = "eDP-1",
    mode = "3840x2400@60",
    position = "0x0",
    scale = "auto",
    vrr = 2,
})