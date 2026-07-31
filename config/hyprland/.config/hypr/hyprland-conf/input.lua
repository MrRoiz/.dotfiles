-- INPUT
-- https://wiki.hypr.land/Configuring/Variables/#input

hl.config({
    input = {
        kb_layout  = "latam",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- https://wiki.hypr.land/Configuring/Variables/#gestures
-- hl.gesture({ fingers = 3, direction = "down", mod = "ALT", action = "close" })
-- hl.gesture({ fingers = 3, direction = "up", mod = "SUPER", scale = 1.5, action = "fullscreen" })
-- hl.gesture({ fingers = 3, direction = "left", scale = 1.5, action = "float" })
