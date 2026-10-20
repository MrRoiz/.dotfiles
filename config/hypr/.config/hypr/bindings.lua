-- Vim-style window navigation without the keyboard's Fn arrow layer.
-- Free SUPER + H/J/K/L by moving the three Omarchy defaults that use J/K/L:
--   SUPER + J (toggle split)      -> SUPER + ALT + J
--   SUPER + K (keybindings)       -> SUPER + CTRL + SHIFT + K
--   SUPER + L (workspace layout)  -> SUPER + ALT + L
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

o.bind("SUPER + ALT + J", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + CTRL + SHIFT + K", "Keybindings", "omarchy-menu-keybindings")
o.bind("SUPER + ALT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

o.bind("SUPER + H", "Focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus right", hl.dsp.focus({ direction = "r" }))

o.bind("SUPER + SHIFT + H", "Swap window left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window right", hl.dsp.window.swap({ direction = "r" }))

-- 60% keyboard: no PRINT key, so Omarchy's PRINT screenshot bind is out of
-- reach. SUPER + SHIFT + C (C = capture) is free — preinstalled web-app
-- bindings are disabled.
o.bind("SUPER + SHIFT + C", "Screenshot", "omarchy-capture-screenshot")

-- Scratchpad: move the stock SUPER + ALT + S "send window to scratchpad"
-- binding to SUPER + SHIFT + S. That key is free here because preinstalled
-- web-app bindings (Google Maps) are disabled. Toggle stays on SUPER + S.
hl.unbind("SUPER + ALT + S")
o.bind("SUPER + SHIFT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
