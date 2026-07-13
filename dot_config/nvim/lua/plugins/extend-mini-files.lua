local function normal_target_window()
  local wins = vim.api.nvim_list_wins()
  table.insert(wins, 1, vim.api.nvim_get_current_win())

  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == "" then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "" then
        return win
      end
    end
  end

  return vim.api.nvim_get_current_win()
end

local function normalize_path(path)
  path = vim.fn.expand(path or vim.fn.getcwd())
  return vim.fs.normalize(vim.uv.fs_realpath(path) or path)
end

local function open_mini_files(path)
  local mini_files = require("mini.files")
  mini_files.open(normalize_path(path), false)

  local win = normal_target_window()
  if vim.api.nvim_win_is_valid(win) then
    mini_files.set_target_window(win)
  end
end

return {
  "nvim-mini/mini.files",
  lazy = false,
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  keys = {
    {
      "<leader>E",
      function()
        open_mini_files(LazyVim.root())
      end,
      desc = "Explorer mini.files (root dir)",
    },
    {
      "<leader>fm",
      function()
        open_mini_files(vim.fn.getcwd())
      end,
      desc = "Explorer mini.files (cwd)",
    },
    {
      "<leader>e",
      function()
        local path = vim.api.nvim_buf_get_name(0)
        if path == "" then
          path = vim.fn.getcwd()
        end
        open_mini_files(path)
      end,
      desc = "Explorer mini.files (current file)",
    },
  },
  opts = {
    windows = {
      width_nofocus = 20,
      width_focus = 50,
      width_preview = 100,
    },
    options = {
      use_as_default_explorer = true,
    },
  },
  config = function(_, opts)
    require("mini.files").setup(opts)

    local group = vim.api.nvim_create_augroup("kyle_mini_files_open", { clear = true })
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local buf = args.data and args.data.buf_id
        if not buf or not vim.api.nvim_buf_is_valid(buf) then
          return
        end

        vim.keymap.set("n", "<CR>", function()
          require("mini.files").go_in({ close_on_file = true })
        end, { buffer = buf, silent = true, desc = "Open file and close mini.files" })

        vim.keymap.set("n", "L", function()
          require("mini.files").go_in({ close_on_file = true })
        end, { buffer = buf, silent = true, desc = "Open file and close mini.files" })
      end,
    })
  end,
}
