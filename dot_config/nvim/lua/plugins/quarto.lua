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

      local language_extensions = {
        python = "py",
        python3 = "py",
        julia = "jl",
        r = "r",
        R = "r",
        bash = "sh",
      }

      local language_names = {
        python3 = "python",
      }

      local function get_notebook_content(path)
        if vim.fn.filereadable(path) ~= 1 then
          return nil
        end

        return table.concat(vim.fn.readfile(path), "\n")
      end

      local function write_empty_python_notebook(path)
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

      local function get_fallback_metadata(filename)
        local path = vim.fn.resolve(vim.fn.expand(filename))
        local content = get_notebook_content(path)
        if not content then
          return nil
        end

        if content:match("^%s*$") then
          write_empty_python_notebook(path)
          content = get_notebook_content(path)
        end

        local ok, notebook = pcall(vim.json.decode, content)
        if not ok or type(notebook) ~= "table" then
          return nil
        end

        local metadata = type(notebook.metadata) == "table" and notebook.metadata or {}
        local kernelspec = type(metadata.kernelspec) == "table" and metadata.kernelspec or {}
        local language_info = type(metadata.language_info) == "table" and metadata.language_info or {}
        local language = kernelspec.language or language_info.name or kernelspec.name or "python"
        language = language_names[language] or language

        return {
          language = language,
          extension = language_extensions[language] or language_extensions[language_info.name] or "py",
        }
      end

      utils.get_ipynb_metadata = function(filename)
        local ok, metadata = pcall(original, filename)
        if ok and type(metadata) == "table" and metadata.language then
          return metadata
        end

        local fallback = get_fallback_metadata(filename)
        if fallback then
          return fallback
        end

        if ok then
          return metadata
        end

        error(metadata)
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
