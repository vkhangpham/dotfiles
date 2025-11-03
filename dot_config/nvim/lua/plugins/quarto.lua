return {
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim", -- REQUIRED by quarto-nvim
      "nvim-lua/plenary.nvim", -- common dep
      -- optional but recommended in general: "nvim-treesitter/nvim-treesitter"
    },
    config = function()
      require("quarto").setup({
        codeRunner = {
          enabled = true,
          default_method = "molten",
          ft_runners = { python = "molten" },
        },
      })

      -- Quarto runner keys for .qmd buffers (don’t use Molten cell ops in .qmd)
      local qr = require("quarto.runner")
      vim.keymap.set("n", "<localleader>rc", qr.run_cell, { silent = true, desc = "Quarto: run cell" })
      vim.keymap.set("n", "<localleader>ra", qr.run_above, { silent = true, desc = "Quarto: run above" })
      vim.keymap.set("n", "<localleader>rA", qr.run_all, { silent = true, desc = "Quarto: run all (lang)" })
    end,
  },
}
