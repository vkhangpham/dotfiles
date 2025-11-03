-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.spell = false
    vim.opt_local.conceallevel = 0
    vim.opt_local.concealcursor = ""
    vim.opt_local.syntax = "off"
  end,
})
--
-- Auto-refresh gitsigns when focus comes back, buffer is entered, or Lazygit exits
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  callback = function()
    local ok, gitsigns = pcall(require, "gitsigns")
    if ok then
      gitsigns.refresh()
    end
    vim.cmd("checktime")
  end,
})

-- If you use Lazygit via :LazyGit or toggleterm
vim.api.nvim_create_autocmd("TermClose", {
  pattern = "*lazygit*",
  callback = function()
    local ok, gitsigns = pcall(require, "gitsigns")
    if ok then
      gitsigns.refresh()
    end
  end,
})
