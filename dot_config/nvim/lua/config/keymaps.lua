-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here. Telescope file mappings live in
-- lua/plugins/extend-telescope.lua so they also act as lazy-load triggers.

vim.keymap.set("n", "<leader>cs", function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("telescope.nvim is not available", vim.log.levels.ERROR)
    return
  end

  builtin.lsp_document_symbols({
    symbols = LazyVim.config.get_kind_filter(),
  })
end, { desc = "LSP Document Symbols (Telescope)" })
