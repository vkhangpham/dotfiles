return {
  {
    "folke/snacks.nvim",
    init = function()
      local group = vim.api.nvim_create_augroup("user_lazyvim_dashboard", { clear = true })

      -- Let LazyVim/Snacks own dashboard startup. This autocmd only restores the
      -- dashboard-local Telescope shortcut.
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "snacks_dashboard",
        callback = function(args)
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(args.buf) then
              return
            end
            vim.keymap.set("n", "f", function()
              require("telescope.builtin").find_files({ hidden = true, no_ignore = true, follow = true })
            end, { buffer = args.buf, silent = true, desc = "Find File (Telescope)" })
          end)
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
      -- mini.files owns explorer mappings.
      { "<leader>e", false },
      { "<leader>E", false },
      { "<leader>fe", false },
      { "<leader>fE", false },

      -- Telescope owns file-search mappings in this config.
      { "<leader>ff", false },
      { "<leader>fF", false },
      { "<leader><space>", false },
    },
  },
}
