-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function telescope_builtin(name, opts)
  return function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if not ok then
      vim.notify("telescope.nvim is not available", vim.log.levels.ERROR)
      return
    end

    builtin[name](opts or {})
  end
end

vim.keymap.set(
  "n",
  "<leader>ff",
  telescope_builtin("find_files", { hidden = true, no_ignore = true, follow = true }),
  { desc = "Find Files (Telescope, hidden + ignored)" }
)

vim.keymap.set(
  "n",
  "<leader><space>",
  telescope_builtin("find_files", { hidden = true, no_ignore = true, follow = true }),
  { desc = "Find Files (Telescope, hidden + ignored)" }
)

vim.keymap.set(
  "n",
  "<leader>fF",
  function()
    telescope_builtin("find_files", { cwd = vim.uv.cwd(), hidden = true, no_ignore = true, follow = true })()
  end,
  { desc = "Find Files cwd (Telescope, hidden + ignored)" }
)

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
