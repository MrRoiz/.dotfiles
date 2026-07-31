-- MONITORS
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

local apps = require("hyprland-conf/apps")

hl.monitor({ output = apps.mainMonitor, mode = "1920x1200@60", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "1920x-300", scale = 1 })
