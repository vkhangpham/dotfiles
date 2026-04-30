return {
  "akinsho/bufferline.nvim",
  init = function()
    local bufferline = require("catppuccin.special.bufferline")
    function bufferline.get()
      return bufferline.get_theme()
    end
  end,
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.always_show_bufferline = true
  end,
}
