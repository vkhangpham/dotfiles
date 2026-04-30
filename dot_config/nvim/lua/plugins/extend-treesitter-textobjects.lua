return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    ft = { "markdown", "quarto" },
    opts = function(_, opts)
      opts.select = opts.select or {}
      opts.select.enable = true
      opts.select.lookahead = true
      opts.select.keymaps = vim.tbl_extend("force", opts.select.keymaps or {}, {
        ac = "@code_cell.outer",
        ic = "@code_cell.inner",
      })
      return opts
    end,
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)

      local function attach(buf)
        local ft = vim.bo[buf].filetype
        if ft ~= "markdown" and ft ~= "quarto" then
          return
        end

        local select = require("nvim-treesitter-textobjects.select")
        local map = function(mode, lhs, query, desc)
          vim.keymap.set(mode, lhs, function()
            select.select_textobject(query, "textobjects")
          end, { buffer = buf, silent = true, desc = desc })
        end

        map({ "x", "o" }, "ac", "@code_cell.outer", "Around code cell")
        map({ "x", "o" }, "ic", "@code_cell.inner", "Inside code cell")
      end

      local group = vim.api.nvim_create_augroup("kyle_notebook_textobjects", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "markdown", "quarto" },
        callback = function(args)
          attach(args.buf)
        end,
      })

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        attach(buf)
      end
    end,
  },
}
