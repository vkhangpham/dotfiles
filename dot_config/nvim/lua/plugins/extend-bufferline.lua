return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    -- Avoid the empty top bufferline on the dashboard/single-buffer views.
    opts.options.always_show_bufferline = false
  end,
}
