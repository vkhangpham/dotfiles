local function python_fence_open(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  local ext = vim.fn.fnamemodify(path, ":e")
  local ft = vim.bo[bufnr].filetype

  if ext == "qmd" or ft == "quarto" then
    return "```{python}"
  end

  return "```python"
end

return {
  {
    "quarto-dev/quarto-nvim",
    keys = {
      {
        "<localleader>cp",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local row = vim.api.nvim_win_get_cursor(0)[1]
          local indent = string.rep(" ", vim.fn.indent(row))

          vim.api.nvim_buf_set_lines(0, row, row, false, {
            indent .. python_fence_open(bufnr),
            indent,
            indent .. "```",
          })
          vim.api.nvim_win_set_cursor(0, { row + 2, #indent })
          vim.cmd("startinsert")
        end,
        desc = "Insert Python code fence for current notebook format",
      },
    },
  },
}
