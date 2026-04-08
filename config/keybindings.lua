return function(wezterm, config)
  -- ========== 优先容易记 其次贴近浏览器行为 再次优先选用较近的ALT. 不常用的用ALT+Enter选择提示==========
  config.keys = {
    {
        key = "Enter",
        mods = "ALT",
        action = wezterm.action.ShowLauncherArgs({
            flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS|KEY_ASSIGNMENTS",
        }),
    },
    -- ========== 窗口管理 ==========
    { key = 'F11',      mods = 'NONE',  action = wezterm.action.ToggleFullScreen },
    -- ========== 标签页管理 ==========
    { key = 't',          mods = 'CTRL',   action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = 'u',          mods = 'CTRL',   action = wezterm.action.SpawnTab{DomainName = 'WSL:Ubuntu-22.04'} },
    { key = 'm',          mods = 'CTRL',   action = wezterm.action.ShowTabNavigator },
    { key = 'w',          mods = 'CTRL',   action = wezterm.action.CloseCurrentPane { confirm = false } },
    { key = 'Tab',          mods = 'CTRL',   action = wezterm.action.ActivateTabRelative(1) },
    { key = 'Tab',          mods = 'CTRL|SHIFT',   action = wezterm.action.ActivateTabRelative(-1) },
    -- ========== 窗格分割 ==========
    { key = '\\',          mods = 'ALT',   action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = '-',          mods = 'ALT',   action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },
    -- ========== 窗格导航 (Leader + 方向键) ==========
    { key = 'LeftArrow',          mods = 'ALT',   action = wezterm.action.ActivatePaneDirection("Left") },
    { key = 'DownArrow',          mods = 'ALT',   action = wezterm.action.ActivatePaneDirection("Down") },
    { key = 'UpArrow',          mods = 'ALT',   action = wezterm.action.ActivatePaneDirection("Up") },
    { key = 'RightArrow',          mods = 'ALT',   action = wezterm.action.ActivatePaneDirection("Right") },
    -- ========== 窗格大小调整 (ALT+Shift + 方向键) ==========
    { key = 'LeftArrow',  mods = 'ALT|SHIFT', action = wezterm.action.AdjustPaneSize { "Left", 5 } },
    { key = 'DownArrow',  mods = 'ALT|SHIFT', action = wezterm.action.AdjustPaneSize { "Down", 5 } },
    { key = 'UpArrow',    mods = 'ALT|SHIFT', action = wezterm.action.AdjustPaneSize { "Up", 5 } },
    { key = 'RightArrow', mods = 'ALT|SHIFT', action = wezterm.action.AdjustPaneSize { "Right", 5 } },
    -- ========== 搜索与命令 ==========
    { key = "f", mods = "CTRL", action = wezterm.action.Search("CurrentSelectionOrEmptyString") },
    -- ========== 滚动 ==========
    { key = "Home", mods = "SHIFT", action = wezterm.action.ScrollToTop },
    { key = "End", mods = "SHIFT", action = wezterm.action.ScrollToBottom },
    { key = 'PageUp', mods = 'SHIFT', action = wezterm.action.ScrollByPage(-1) },
    { key = 'PageDown', mods = 'SHIFT', action = wezterm.action.ScrollByPage(1) },
    { key = 'UpArrow', mods = 'SHIFT', action = wezterm.action.ScrollByLine(-1) },
    { key = 'DownArrow', mods = 'SHIFT', action = wezterm.action.ScrollByLine(1) },
  }
   -- ========== 标签页直接选择 ==========
  for i = 1, 8 do
    -- CTRL + number to activate that tab
    table.insert(config.keys, {
      key = tostring(i),
      mods = 'CTRL',
      action = wezterm.action.ActivateTab(i - 1),
    })
    -- CTRL+SHIFT+ number to activate that tab from right-side
    table.insert(config.keys, {
      key = tostring(i),
      mods = 'CTRL|SHIFT',
      action = wezterm.action.ActivateTab(- i),
    })
  end  
end
