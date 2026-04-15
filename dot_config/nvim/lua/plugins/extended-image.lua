return {
  "3rd/image.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = function()
    local term = (vim.env.TERM or ""):lower()
    local term_program = (vim.env.TERM_PROGRAM or ""):lower()
    local tmux_client = ""

    if vim.env.TMUX then
      local ok, result = pcall(vim.fn.system, { "tmux", "display-message", "-p", "#{client_termname} #{client_termtype}" })
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

    return {
      backend = (is_ghostty or is_kitty) and "kitty" or "ueberzug",
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
    }
  end,
}
