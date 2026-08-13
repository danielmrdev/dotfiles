-- Personal workspace layout
-- Monitors: DP-3 = left, DP-4 = right

-- Stable workspace defaults
hl.workspace_rule({ workspace = "1", monitor = "DP-3", default_name = "A", persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-4", default_name = "B", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "DP-3", default_name = "P", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "DP-4", default_name = "T", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "DP-3", default_name = "D", persistent = true })
hl.workspace_rule({ workspace = "6", monitor = "DP-4", persistent = true })
hl.workspace_rule({ workspace = "7", monitor = "DP-4" })
hl.workspace_rule({ workspace = "8", monitor = "DP-4" })

-- App placement
o.window("Alacritty", { workspace = "1" })
o.window("zen", { workspace = "2" })
o.window("obsidian", { workspace = "5" })
o.window("org.mozilla.Thunderbird", { workspace = "4" })
o.window("chrome-teams.cloud.microsoft__-Default", { workspace = "4" })
o.window("chrome-outlook.cloud.microsoft__-Default", { workspace = "4" })
o.window("org.remmina.Remmina", { workspace = "8" })
o.window("pith", { workspace = "3" })

-- Toggle between current and last focused workspace
o.bind("SUPER + code:49", "Toggle current and last workspace", hl.dsp.focus({ workspace = "previous" }))

-- Move current workspace to the other monitor
o.bind("SUPER + CTRL + M", "Move current workspace to other monitor", hl.dsp.workspace.move({ monitor = "+1" }))

-- Tab group for teams + outlook on ws 4, only when the laptop monitor is the
-- sole display. Docked (2 externals): ws 4 lives on DP-4, keep them separate.
local function laptop_only_monitor()
    local f = io.popen("hyprctl monitors -j")
    if not f then
        return false
    end
    local out = f:read("*a")
    f:close()
    local external = false
    for name in out:gmatch('"name"%s*:%s*"([^"]+)"') do
        if name ~= "eDP-1" then
            external = true
        end
    end
    return not external
end

local ws4_teams = hl.window_rule({
    name = "ws4-group-teams",
    match = { class = "chrome-teams.cloud.microsoft__-Default" },
    group = "set",
})
local ws4_outlook = hl.window_rule({
    name = "ws4-group-outlook",
    match = { class = "chrome-outlook.cloud.microsoft__-Default" },
    group = "set",
})

local function set_ws4_grouping(enabled)
    ws4_teams:set_enabled(enabled)
    ws4_outlook:set_enabled(enabled)
end

set_ws4_grouping(laptop_only_monitor())
hl.on("monitor.added", function() set_ws4_grouping(laptop_only_monitor()) end)
hl.on("monitor.removed", function() set_ws4_grouping(laptop_only_monitor()) end)
