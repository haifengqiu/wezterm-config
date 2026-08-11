local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- 默认用 Windows PowerShell
config.default_prog = { 'powershell.exe', '-NoLogo' }
config.default_cwd = 'D:/workspace'

-- require("config.appearance")(wezterm, config)
require("config.keybindings")(wezterm, config)
require("config.status")(wezterm, config)
require("config.ssh")(wezterm, config)

return config
