return {
  "nvim-telescope/telescope.nvim",
  priority = 1000,
  keys = {
    -- Override default find_files to show hidden files
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
      end,
      desc = "Find Files (with hidden and ignored)",
    },
  },
  opts = {
    defaults = {
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden", -- Show hidden files
      },
    },
    pickers = {
      find_files = {
        hidden = true, -- Show hidden files by default
      },
    },
  },
}
