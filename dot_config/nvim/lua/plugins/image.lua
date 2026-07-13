local image_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }

local function safe_hijack_path(path)
  if path == "" or path:find("^minifiles://") ~= nil then
    return nil
  end

  local absolute_path = vim.fn.fnamemodify(path, ":p")
  if vim.uv.fs_stat(absolute_path) ~= nil then
    return path
  end

  local unescaped_path = path:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
  absolute_path = vim.fn.fnamemodify(unescaped_path, ":p")
  if vim.uv.fs_stat(absolute_path) ~= nil then
    return unescaped_path
  end

  return nil
end

local function setup_safe_file_hijack(image)
  local group = vim.api.nvim_create_augroup("kyle_image_file_hijack", { clear = true })

  vim.api.nvim_create_autocmd({ "WinNew", "BufWinEnter", "TabEnter" }, {
    group = group,
    pattern = image_file_patterns,
    callback = function(event)
      if not image.is_enabled() then
        return
      end

      local buf = event.buf
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      local path = safe_hijack_path(vim.api.nvim_buf_get_name(buf))
      if path == nil then
        return
      end

      pcall(image.hijack_buffer, path, vim.api.nvim_get_current_win(), buf)
    end,
  })
end

local function pick_backend()
  local term = (vim.env.TERM or ""):lower()
  local term_program = (vim.env.TERM_PROGRAM or ""):lower()
  local tmux_client = ""

  if vim.env.TMUX then
    local ok, result =
      pcall(vim.fn.system, { "tmux", "display-message", "-p", "#{client_termname} #{client_termtype}" })
    if ok and vim.v.shell_error == 0 then
      tmux_client = vim.trim(result):lower()
    end
  end

  local is_ghostty = term:find("ghostty", 1, true) ~= nil
    or term_program:find("ghostty", 1, true) ~= nil
    or tmux_client:find("ghostty", 1, true) ~= nil
  local is_kitty = term:find("kitty", 1, true) ~= nil
    or term_program:find("kitty", 1, true) ~= nil
    or tmux_client:find("kitty", 1, true) ~= nil
  local has_ueberzugpp = vim.fn.executable("ueberzugpp") == 1

  if is_ghostty or is_kitty then
    return "kitty"
  end

  if has_ueberzugpp and vim.env.TMUX then
    return "ueberzug"
  end

  return "kitty"
end

return {
  "3rd/image.nvim",
  ft = { "markdown", "quarto" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = function()
    return {
      backend = pick_backend(),
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = false,
        },
      },
      max_width = 100,
      max_height = 12,
      max_width_window_percentage = math.huge,
      max_height_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "scrollview", "scrollview_sign" },
      editor_only_render_when_focused = false,
      tmux_show_only_in_active_window = false,
      -- image.nvim's default autocmd also matches mini.files virtual
      -- buffers like minifiles://.../image.png and then tries to read
      -- that URI as a real file. Use a filtered autocmd below instead.
      hijack_file_patterns = {},
    }
  end,
  config = function(_, opts)
    local image = require("image")
    image.setup(opts)
    setup_safe_file_hijack(image)
  end,
}
