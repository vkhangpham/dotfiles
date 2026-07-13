local python_host = vim.fn.expand("~/.nvim/bin/python")
vim.g.python3_host_prog = python_host

local function prepend_path(path)
  path = vim.fn.expand(path)
  if vim.fn.isdirectory(path) ~= 1 then
    return
  end

  local sep = package.config:sub(1, 1) == "\\" and ";" or ":"
  local normalized = vim.fs.normalize(path)

  for entry in string.gmatch(vim.env.PATH or "", "[^" .. sep .. "]+") do
    if vim.fs.normalize(entry) == normalized then
      return
    end
  end

  vim.env.PATH = path .. sep .. (vim.env.PATH or "")
end

prepend_path(vim.fn.fnamemodify(python_host, ":h"))

-- Compatibility for older plugin healthchecks on Neovim 0.12+.
if vim.health then
  vim.health.report_start = vim.health.report_start or vim.health.start
  vim.health.report_ok = vim.health.report_ok or vim.health.ok
  vim.health.report_warn = vim.health.report_warn or vim.health.warn
  vim.health.report_error = vim.health.report_error or vim.health.error
end

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
