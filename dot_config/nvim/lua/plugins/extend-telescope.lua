local function selection_window()
  local wins = vim.api.nvim_list_wins()
  table.insert(wins, 1, vim.api.nvim_get_current_win())

  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == "" then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "" then
        return win
      end
    end
  end

  return 0
end

return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({ hidden = true, no_ignore = true, follow = true })
      end,
      desc = "Find Files (Telescope, hidden + ignored)",
    },
    {
      "<leader><space>",
      function()
        require("telescope.builtin").find_files({ hidden = true, no_ignore = true, follow = true })
      end,
      desc = "Find Files (Telescope, hidden + ignored)",
    },
    {
      "<leader>fF",
      function()
        require("telescope.builtin").find_files({ cwd = vim.uv.cwd(), hidden = true, no_ignore = true, follow = true })
      end,
      desc = "Find Files cwd (Telescope, hidden + ignored)",
    },
  },
  opts = function(_, opts)
    opts = opts or {}
    opts.defaults = opts.defaults or {}

    opts.defaults.get_selection_window = selection_window
    opts.defaults.vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
    }

    opts.pickers = opts.pickers or {}
    opts.pickers.find_files = vim.tbl_deep_extend("force", opts.pickers.find_files or {}, {
      hidden = true,
      no_ignore = true,
      follow = true,
    })

    return opts
  end,
}
