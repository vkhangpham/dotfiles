local M = {}

function M.activate_quarto()
  local ok, quarto = pcall(require, "quarto")
  if ok and type(quarto.activate) == "function" then
    quarto.activate()
  end
end

function M.set_molten_defaults_for_ft(ft)
  ft = ft or vim.bo.filetype
  local markdown_like = ft == "markdown" or ft == "quarto"

  vim.g.molten_virt_text_output = true
  vim.g.molten_virt_lines_off_by_1 = markdown_like
end

function M.insert_python_codeblock()
  local ft = vim.bo.filetype
  local fence = ft == "quarto" and "```{python}" or "```python"
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]

  vim.api.nvim_buf_set_lines(0, row, row, false, { fence, "", "```", "" })
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  vim.cmd.startinsert()
end

return M
