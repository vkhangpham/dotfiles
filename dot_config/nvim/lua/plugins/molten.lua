local uv = vim.uv or vim.loop

local function kernel_specs()
  local host_python = vim.g.python3_host_prog or vim.fn.expand("~/.virtualenvs/neovim/bin/python")
  local output = vim.fn.system({ host_python, "-m", "jupyter", "kernelspec", "list", "--json" })
  if vim.v.shell_error ~= 0 then
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, output)
  if not ok or type(decoded) ~= "table" or type(decoded.kernelspecs) ~= "table" then
    return {}
  end

  return decoded.kernelspecs
end

local function kernel_exists(name)
  return kernel_specs()[name] ~= nil
end

local function slugify(str)
  local slug = str:gsub("[^%w]+", "-"):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
  return slug ~= "" and slug or "project"
end

local function find_local_venv(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  local start = path ~= "" and vim.fs.dirname(path) or uv.cwd()
  local matches = vim.fs.find(".venv", { path = start, upward = true, type = "directory", limit = 1 })
  local venv_dir = matches[1]
  if not venv_dir then
    return nil
  end

  local python = venv_dir .. "/bin/python"
  if vim.fn.executable(python) ~= 1 then
    return nil
  end

  return venv_dir, python
end

local function ensure_local_venv_kernel(bufnr)
  local venv_dir, python = find_local_venv(bufnr)
  if not venv_dir then
    return nil
  end

  vim.fn.system({ python, "-c", "import ipykernel" })
  if vim.v.shell_error ~= 0 then
    vim.notify(
      "Local .venv found, but ipykernel missing. Run: uv pip install --python .venv/bin/python ipykernel",
      vim.log.levels.WARN
    )
    return nil
  end

  local project_root = vim.fs.dirname(venv_dir)
  local project_name = vim.fs.basename(project_root)
  local kernel_name = ("local-%s-%s"):format(slugify(project_name), vim.fn.sha256(project_root):sub(1, 8))
  local kernel_dir = vim.fn.expand("~/.local/share/jupyter/kernels/" .. kernel_name)
  local kernel_path = kernel_dir .. "/kernel.json"
  local kernel_spec = vim.json.encode({
    argv = { python, "-m", "ipykernel_launcher", "-f", "{connection_file}" },
    display_name = ("Python (%s .venv)"):format(project_name ~= "" and project_name or ".venv"),
    language = "python",
    metadata = { debugger = true },
  })

  vim.fn.mkdir(kernel_dir, "p")

  local current_spec = ""
  if uv.fs_stat(kernel_path) then
    current_spec = table.concat(vim.fn.readfile(kernel_path), "\n")
  end
  if current_spec ~= kernel_spec then
    vim.fn.writefile({ kernel_spec }, kernel_path)
  end

  return kernel_name
end

local function init_python_kernel()
  local bufnr = vim.api.nvim_get_current_buf()
  local local_kernel = ensure_local_venv_kernel(bufnr)
  if local_kernel then
    vim.cmd("MoltenInit " .. vim.fn.fnameescape(local_kernel))
    return
  end

  local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
  if venv ~= nil then
    local active_kernel = vim.fn.fnamemodify(venv, ":t")
    if kernel_exists(active_kernel) then
      vim.cmd("MoltenInit " .. vim.fn.fnameescape(active_kernel))
      return
    end
  end

  if kernel_exists("python3-neovim") then
    vim.cmd("MoltenInit python3-neovim")
    return
  end

  vim.cmd("MoltenInit")
end

return {
  { import = "lazyvim.plugins.extras.lang.python" },

  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    lazy = false,
    init = function()
      vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/neovim/bin/python")
      vim.g.molten_auto_open_output = false
      vim.g.molten_auto_init_behavior = "init"
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_image_location = "both"
      vim.g.molten_output_win_max_height = 20
    end,
    keys = {
      {
        "<localleader>mi",
        init_python_kernel,
        desc = "Molten init Python kernel",
      },
      { "<localleader>e", ":MoltenEvaluateOperator<CR>", desc = "Molten evaluate operator", silent = true, mode = "n" },
      { "<localleader>rr", ":MoltenReevaluateCell<CR>", desc = "Molten re-evaluate cell", silent = true, mode = "n" },
      { "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", desc = "Molten open output", silent = true, mode = "n" },
      { "<localleader>oh", ":MoltenHideOutput<CR>", desc = "Molten hide output", silent = true, mode = "n" },
      { "<localleader>md", ":MoltenDelete<CR>", desc = "Molten delete cell", silent = true, mode = "n" },
      { "<localleader>rl", ":MoltenEvaluateLine<CR>", desc = "Molten evaluate line", silent = true, mode = "n" },
      { "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", desc = "Molten evaluate selection", silent = true, mode = "v" },
    },
  },
}
