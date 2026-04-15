local uv = vim.uv or vim.loop
local home = uv.os_homedir()

local function is_dotfile_path(path)
  return path ~= "" and path:find("^" .. vim.pesc(home) .. "/%.") ~= nil
end

local function sync_dotfile_diagnostics(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local disabled = is_dotfile_path(vim.api.nvim_buf_get_name(bufnr))

  if disabled == vim.b[bufnr].dotfile_diagnostics_disabled then
    return
  end

  vim.diagnostic.enable(not disabled, { bufnr = bufnr })
  if disabled then
    vim.diagnostic.reset(nil, bufnr)
  end
  vim.b[bufnr].dotfile_diagnostics_disabled = disabled
end

local function filter_client_diagnostics(client)
  if client._dotfile_diagnostics_filtered then
    return
  end

  local publish = client.handlers["textDocument/publishDiagnostics"] or vim.lsp.handlers["textDocument/publishDiagnostics"]

  client.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
    if result and result.uri and is_dotfile_path(vim.uri_to_fname(result.uri)) then
      vim.diagnostic.reset(nil, vim.uri_to_bufnr(result.uri))
      return
    end

    return publish(err, result, ctx, config)
  end

  client._dotfile_diagnostics_filtered = true
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = { enabled = false },
      },
    },
    init = function()
      local group = vim.api.nvim_create_augroup("user_disable_dotfile_diagnostics", { clear = true })

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufFilePost" }, {
        group = group,
        callback = function(event)
          sync_dotfile_diagnostics(event.buf)
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(event)
          sync_dotfile_diagnostics(event.buf)

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client then
            filter_client_diagnostics(client)
          end
        end,
      })
    end,
  },
}
