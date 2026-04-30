local function pick_backend()
  local env = vim.env
  local in_tmux = env.TMUX and env.TMUX ~= ""
  local in_ghostty = env.GHOSTTY_RESOURCES_DIR and env.GHOSTTY_RESOURCES_DIR ~= ""
  local has_ueberzugpp = vim.fn.executable("ueberzugpp") == 1

  if in_ghostty then
    return "kitty"
  end

  if has_ueberzugpp and in_tmux then
    return "ueberzug"
  end

  return "kitty"
end

return {
  "3rd/image.nvim",
  opts = {
    backend = pick_backend(),
    processor = "magick_cli",
  },
  dependencies = { "nvim-lua/plenary.nvim" },
}
