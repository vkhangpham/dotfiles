return {
  {
    "folke/snacks.nvim",
    init = function()
      local group = vim.api.nvim_create_augroup("user_lazyvim_dashboard", { clear = true })

      local function show_dashboard()
        vim.schedule(function()
          local ok, Snacks = pcall(require, "snacks")
          if ok and Snacks.dashboard then
            Snacks.dashboard()
          end
        end)
      end

      local function current_buffer_is_empty()
        if vim.api.nvim_buf_get_name(0) ~= "" or vim.bo.buftype ~= "" or vim.bo.filetype ~= "" then
          return false
        end

        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        return #lines == 1 and lines[1] == ""
      end

      vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        once = true,
        callback = function()
          if vim.fn.has("stdin") == 1 then
            return
          end

          local argc = vim.fn.argc()

          if argc == 1 then
            local arg = vim.fn.argv(0)
            if vim.fn.isdirectory(arg) == 1 then
              local dir = vim.fn.fnamemodify(arg, ":p")
              local dir_buf = vim.api.nvim_get_current_buf()
              vim.fn.chdir(dir)
              vim.cmd.enew()
              pcall(vim.api.nvim_buf_delete, dir_buf, { force = true })
              show_dashboard()
              return
            end
          end

          if argc > 0 then
            return
          end

          if current_buffer_is_empty() then
            show_dashboard()
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
