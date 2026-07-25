local function is_target_window(win)
  -- Floating windows are never a valid target; that includes mini.files' own
  -- windows, which would otherwise get the opened file written into them.
  if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.bo[buf].filetype

  if ft == "minifiles" then
    return false
  end

  -- A real file/empty edit window is ideal. The Snacks dashboard is also a
  -- valid target: opening a file should replace the dashboard rather than be
  -- redirected into the explorer.
  return vim.bo[buf].buftype == "" or ft == "snacks_dashboard"
end

local function preferred_target_window()
  local current = vim.api.nvim_get_current_win()
  if is_target_window(current) then
    return current
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if is_target_window(win) then
      return win
    end
  end

  return current
end

local function normalize_path(path)
  path = vim.fn.expand(path or vim.fn.getcwd())
  return vim.fs.normalize(vim.uv.fs_realpath(path) or path)
end

local function open_mini_files(path)
  local mini_files = require("mini.files")

  -- Resolve the target before opening. Afterwards the current window is the
  -- mini.files float, so a post-open fallback would target the explorer itself.
  local win = preferred_target_window()
  mini_files.open(normalize_path(path), false)

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
