-- Keep editor and floating windows transparent so Catppuccin blends with the
-- terminal. Leave lualine/statusline highlights alone so LazyVim's normal
-- bottom statusline remains styled.

local function make_transparent(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok then
    return
  end

  hl.bg = nil
  hl.ctermbg = nil
  hl.default = nil
  vim.api.nvim_set_hl(0, name, hl)
end

local static_groups = {
  -- editor/background
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "Pmenu",
  "Terminal",
  "EndOfBuffer",
  "FoldColumn",
  "Folded",
  "SignColumn",
  "LineNr",
  "CursorLineNr",
  "WhichKeyFloat",
  "TelescopeBorder",
  "TelescopeNormal",
  "TelescopePromptBorder",
  "TelescopePromptTitle",

  -- top UI chrome
  "TabLine",
  "TabLineFill",
  "TabLineSel",
  "WinBar",
  "WinBarNC",

  -- bufferline common groups
  "BufferLineFill",
  "BufferLineBackground",
  "BufferLineBuffer",
  "BufferLineBufferSelected",
  "BufferLineBufferVisible",
  "BufferLineTab",
  "BufferLineTabSelected",
  "BufferLineTabClose",
  "BufferLineCloseButton",
  "BufferLineCloseButtonSelected",
  "BufferLineSeparator",
  "BufferLineSeparatorSelected",
  "BufferLineIndicatorSelected",

  -- file explorers
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "NeoTreeVertSplit",
  "NeoTreeWinSeparator",
  "NeoTreeEndOfBuffer",
  "NvimTreeNormal",
  "NvimTreeVertSplit",
  "NvimTreeEndOfBuffer",

  -- notifications
  "NotifyINFOBody",
  "NotifyERRORBody",
  "NotifyWARNBody",
  "NotifyTRACEBody",
  "NotifyDEBUGBody",
  "NotifyINFOTitle",
  "NotifyERRORTitle",
  "NotifyWARNTitle",
  "NotifyTRACETitle",
  "NotifyDEBUGTitle",
  "NotifyINFOBorder",
  "NotifyERRORBorder",
  "NotifyWARNBorder",
  "NotifyTRACEBorder",
  "NotifyDEBUGBorder",
}

local dynamic_patterns = {
  "^BufferLine",
}

local function apply_transparency()
  for _, name in ipairs(static_groups) do
    make_transparent(name)
  end

  for _, name in ipairs(vim.fn.getcompletion("", "highlight")) do
    for _, pattern in ipairs(dynamic_patterns) do
      if name:match(pattern) then
        make_transparent(name)
        break
      end
    end
  end
end

apply_transparency()

local group = vim.api.nvim_create_augroup("UserTransparentChrome", { clear = true })

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "UIEnter" }, {
  group = group,
  callback = function()
    vim.schedule(apply_transparency)
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = { "VeryLazy", "LazyLoad", "LazyDone" },
  callback = function()
    vim.schedule(apply_transparency)
  end,
})
