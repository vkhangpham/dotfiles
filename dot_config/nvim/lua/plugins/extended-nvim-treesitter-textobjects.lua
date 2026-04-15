return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    keys = {
      {
        "ac",
        mode = { "x", "o" },
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@codechunk.outer", "textobjects")
        end,
        desc = "Select around notebook code cell",
      },
      {
        "ic",
        mode = { "x", "o" },
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@codechunk.inner", "textobjects")
        end,
        desc = "Select inside notebook code cell",
      },
    },
    opts = function(_, opts)
      opts.select = opts.select or {}
      opts.select.enable = true
      if opts.select.lookahead == nil then
        opts.select.lookahead = true
      end

      opts.select.keymaps = opts.select.keymaps or {}
      opts.select.keymaps["ac"] = "@codechunk.outer"
      opts.select.keymaps["ic"] = "@codechunk.inner"

      opts.select.selection_modes = opts.select.selection_modes or {}
      opts.select.selection_modes["@codechunk.outer"] = "V"
      opts.select.selection_modes["@codechunk.inner"] = "V"
    end,
  },
}
