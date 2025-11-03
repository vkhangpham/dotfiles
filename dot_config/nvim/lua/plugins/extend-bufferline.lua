return {
  "akinsho/bufferline.nvim",
  init = function()
    local bufferline = require("catppuccin.special.bufferline")
    function bufferline.get()
      return bufferline.get_theme()
    end
  end,
}
