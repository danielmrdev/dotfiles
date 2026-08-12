-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Personal setup: laptop eDP-1 at 1.25; docked dual 4K (DP-3 left, DP-4 right) at 1.6
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
hl.monitor({ output = "DP-3", mode = "3840x2160@60", position = "0x0", scale = 1.6 })
hl.monitor({ output = "DP-4", mode = "3840x2160@60", position = "2400x0", scale = 1.6 })
