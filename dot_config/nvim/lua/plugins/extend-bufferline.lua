return {
  "akinsho/bufferline.nvim",
  init = function()
    local bufferline = require("catppuccin.groups.integrations.bufferline")
    function bufferline.get()
      return bufferline.get_theme()
    end
  end,
}
