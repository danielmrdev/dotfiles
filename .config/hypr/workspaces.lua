-- Personal workspace layout
-- Monitors: DP-3 = left, DP-4 = right

-- Stable workspace defaults
hl.workspace_rule({ workspace = "1", monitor = "DP-3", default_name = "A", persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-4", default_name = "B", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "DP-4", default_name = "D", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "DP-3", default_name = "T", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "DP-3" })
hl.workspace_rule({ workspace = "6", monitor = "DP-3" })
hl.workspace_rule({ workspace = "7", monitor = "DP-4" })
hl.workspace_rule({ workspace = "8", monitor = "DP-4" })

-- App placement
o.window("Alacritty", { workspace = "1" })
o.window("zen", { workspace = "2" })
o.window("chrome-cmnidpelfjhecdgmgpmdaehiajphajhi-Default", { workspace = "3" })
o.window("obsidian", { workspace = "3 silent" })
o.window("org.mozilla.Thunderbird", { workspace = "4" })
o.window("chrome-teams.cloud.microsoft__-Default", { workspace = "4" })
o.window("chrome-outlook.cloud.microsoft__-Default", { workspace = "4" })
o.window("org.remmina.Remmina", { workspace = "8" })
o.window("pith", { workspace = "7" })

-- Toggle between current and last focused workspace
o.bind("SUPER + code:49", "Toggle current and last workspace", hl.dsp.focus({ workspace = "previous" }))

-- Move current workspace to the other monitor
o.bind("SUPER + CTRL + M", "Move current workspace to other monitor", hl.dsp.workspace.move({ monitor = "+1" }))
