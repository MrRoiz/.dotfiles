-- WINDOWS AND WORKSPACES
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name = "suppress-maximize-events",
    match = {
        class = ".*",
    },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.layer_rule({
    name = "vicinae-blur",
    match = {
        namespace = "vicinae",
    },

    blur         = true,
    ignore_alpha = 0,
})

-- disable animation for vicinae only
hl.layer_rule({
    name = "vicinae-no-animation",
    match = {
        namespace = "vicinae",
    },

    no_anim = true,
})

-- Custom rules
-- Privacy sharescreen protection
hl.window_rule({
    name = "avoid-1password-screenshare",
    match = {
        class = "^(1[pP]assword)$",
    },

    center          = true,
    float           = true,
    size            = { 1100, 900 },
    no_screen_share = true,
})

hl.window_rule({
    name = "float-calculator",
    match = {
        title = "Calculator",
    },

    float  = true,
    center = true,
    size   = { 400, 600 },
})

hl.window_rule({
    name = "float-pavucontrol",
    match = {
        class = "^(org.pulseaudio.pavucontrol)$",
    },

    float  = true,
    center = true,
    size   = { 900, 600 },
})

hl.window_rule({
    name = "float-localsend",
    match = {
        title = "LocalSend",
    },

    float  = true,
    center = true,
    size   = { 400, 600 },
})

hl.window_rule({
    name = "float-better-control",
    match = {
        class = "better_control.py",
    },

    float  = true,
    center = true,
})

hl.window_rule({
    name = "float-steam-chat",
    match = {
        title = "(Friends List)",
    },

    float  = true,
    center = true,
    size   = { 400, 600 },
})

-- hl.window_rule({
--     name = "float-slack-huddle-preview",
--     match = {
--         title = "Slack - Huddle Preview",
--     },
--
--     float  = true,
--     center = true,
-- })
