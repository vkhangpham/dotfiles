-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local markdown_noise_filetypes = {
  markdown = true,
  ["markdown.mdx"] = true,
  quarto = true,
}

local function disable_markdown_noise(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if not markdown_noise_filetypes[vim.bo[bufnr].filetype] then
    return
  end

  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    pcall(vim.api.nvim_set_option_value, "spell", false, { win = win })
  end

  vim.diagnostic.enable(false, { bufnr = bufnr })
  vim.diagnostic.reset(nil, bufnr)
end

local markdown_group = vim.api.nvim_create_augroup("user_disable_markdown_noise", { clear = true })

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "LspAttach" }, {
  group = markdown_group,
  callback = function(event)
    disable_markdown_noise(event.buf)
  end,
})
