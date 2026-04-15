return {
  {
    "folke/snacks.nvim",
    init = function()
      local group = vim.api.nvim_create_augroup("user_lazyvim_dashboard", { clear = true })

      vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        once = true,
        callback = function()
          if vim.fn.argc() > 0 or vim.fn.has("stdin") == 1 then
            return
          end

          if vim.api.nvim_buf_get_name(0) ~= "" or vim.bo.buftype ~= "" or vim.bo.filetype ~= "" then
            return
          end

          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          if #lines == 1 and lines[1] == "" then
            vim.schedule(function()
              local ok, Snacks = pcall(require, "snacks")
              if ok and Snacks.dashboard then
                Snacks.dashboard()
              end
            end)
          end
        end,
      })
    end,
    opts = {
      dashboard = {
        enabled = true,
      },
      explorer = {
        enabled = false,
      },
      scroll = {
        enabled = false,
      },
    },
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
      { "<leader>fe", false },
      { "<leader>fE", false },
    },
  },
}
