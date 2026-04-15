return {
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown" },
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
      "benlubas/molten-nvim",
    },
    opts = {
      lspFeatures = {
        enabled = true,
        chunks = "all",
        languages = { "python" },
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
    keys = {
      {
        "<localleader>rc",
        function()
          require("quarto.runner").run_cell()
        end,
        desc = "Quarto run cell",
      },
      {
        "<localleader>ra",
        function()
          require("quarto.runner").run_above()
        end,
        desc = "Quarto run cell and above",
      },
      {
        "<localleader>rA",
        function()
          require("quarto.runner").run_all()
        end,
        desc = "Quarto run all cells",
      },
      {
        "<localleader>rl",
        function()
          require("quarto.runner").run_line()
        end,
        desc = "Quarto run line",
      },
      {
        "<localleader>r",
        function()
          require("quarto.runner").run_range()
        end,
        desc = "Quarto run visual range",
        mode = "v",
      },
    },
  },

  {
    "jmbuhr/otter.nvim",
    lazy = true,
    opts = {},
  },

  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
      custom_language_formatting = {
        python = {
          extension = "md",
          style = "markdown",
          force_ft = "markdown",
        },
      },
    },
    config = function(_, opts)
      local utils = require("jupytext.utils")
      local original = utils.get_ipynb_metadata

      utils.get_ipynb_metadata = function(filename)
        local path = vim.fn.resolve(vim.fn.expand(filename))
        if vim.fn.filereadable(path) == 1 then
          local lines = vim.fn.readfile(path)
          local content = table.concat(lines, "\n")
          if content:match("^%s*$") then
            local notebook = {
              cells = {},
              metadata = {
                kernelspec = {
                  display_name = "Python 3 (Neovim)",
                  language = "python",
                  name = "python3-neovim",
                },
                language_info = {
                  name = "python",
                },
              },
              nbformat = 4,
              nbformat_minor = 5,
            }
            vim.fn.writefile({ vim.json.encode(notebook) }, path)
          end
        end
        return original(filename)
      end

      require("jupytext").setup(opts)
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "markdown",
        "markdown_inline",
        "python",
        "json",
        "yaml",
      })
    end,
  },
}
