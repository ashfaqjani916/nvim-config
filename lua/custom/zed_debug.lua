-- Zed debug scenarios for nvim-dap: reads .zed/debug.json (and Zed's global debug.json)
-- so one file drives the debugger in both editors. Format: https://zed.dev/docs/debugger
local M = {}

-- Zed adapter name -> nvim-dap adapter (registered by nvim-dap-go, nvim-dap-python, rustaceanvim)
M.adapters = { Delve = 'go', Debugpy = 'python', CodeLLDB = 'codelldb' }

--- Strip // and /* */ comments and trailing commas (Zed files are JSONC), leaving strings intact.
---@param text string
---@return string
function M.strip_jsonc(text)
  local out, i, n, in_string = {}, 1, #text, false
  while i <= n do
    local c, two = text:sub(i, i), text:sub(i, i + 1)
    if in_string then
      table.insert(out, c)
      if c == '\\' then
        table.insert(out, text:sub(i + 1, i + 1))
        i = i + 1
      elseif c == '"' then
        in_string = false
      end
    elseif two == '//' then
      i = (text:find('\n', i, true) or n + 1) - 1
    elseif two == '/*' then
      i = (select(2, text:find('*/', i + 2, true)) or n)
    elseif c == ']' or c == '}' then
      local j = #out
      while j > 0 and out[j]:match '%s' do
        j = j - 1
      end
      if out[j] == ',' then table.remove(out, j) end
      table.insert(out, c)
    else
      if c == '"' then in_string = true end
      table.insert(out, c)
    end
    i = i + 1
  end
  return table.concat(out)
end

--- Name of the function/method around the cursor, via treesitter (Zed's $ZED_SYMBOL).
local function symbol_at_cursor(bufnr)
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })
  if not ok then return nil end
  local kinds = { function_declaration = true, method_declaration = true, function_definition = true, function_item = true }
  while node do
    if kinds[node:type()] then
      local name = node:field('name')[1]
      return name and vim.treesitter.get_node_text(name, bufnr)
    end
    node = node:parent()
  end
end

--- Zed task variables for a buffer. Missing ones stay nil, so scenarios using them are hidden, as in Zed.
-- shortcut: $ZED_SELECTED_TEXT and $ZED_CUSTOM_RUST_PACKAGE are never set; add them if a scenario needs them.
---@param bufnr integer
---@param root string
function M.variables(bufnr, root)
  local file = vim.api.nvim_buf_get_name(bufnr)
  local vars = { ZED_WORKTREE_ROOT = root, ZED_MAIN_GIT_WORKTREE = root }
  if file ~= '' then
    local dir = vim.fs.dirname(file)
    local cursor = vim.api.nvim_get_current_buf() == bufnr and vim.api.nvim_win_get_cursor(0) or { 1, 0 }
    vars.ZED_FILE = file
    vars.ZED_FILENAME = vim.fs.basename(file)
    vars.ZED_DIRNAME = dir
    vars.ZED_STEM = vim.fn.fnamemodify(file, ':t:r')
    vars.ZED_RELATIVE_FILE = vim.fs.relpath(root, file) or file
    vars.ZED_RELATIVE_DIR = vim.fs.relpath(root, dir) or dir
    vars.ZED_ROW = tostring(cursor[1])
    vars.ZED_COLUMN = tostring(cursor[2] + 1)
    vars.ZED_SYMBOL = symbol_at_cursor(bufnr)
  end
  local ft = vim.bo[bufnr].filetype
  vars.ZED_LANGUAGE = ({ go = 'Go', python = 'Python', rust = 'Rust' })[ft] or (ft ~= '' and ft or nil)
  return vars
end

--- Replace $ZED_X, ${ZED_X} and ${ZED_X:default} everywhere in a value.
--- Returns nil when a variable has no value and no default.
function M.substitute(value, vars)
  if type(value) == 'table' then
    local result = {}
    for k, v in pairs(value) do
      local sub = M.substitute(v, vars)
      if sub == nil then return nil end
      result[k] = sub
    end
    return result
  end
  if type(value) ~= 'string' then return value end
  local missing = false
  local function lookup(name, default)
    local v = vars[name] or default
    if v == nil then missing = true end
    return v or ''
  end
  local s = value:gsub('%${(ZED_[%w_]+):([^}]*)}', lookup):gsub('%${(ZED_[%w_]+)}', function(name) return lookup(name) end)
  s = s:gsub('%$(ZED_[%w_]+)', function(name) return lookup(name) end)
  if missing then return nil end
  return (s:gsub('^~', vim.env.HOME))
end

--- Turn one Zed scenario into an nvim-dap configuration (nil if it can't run here).
function M.to_dap(scenario, vars, root, tasks)
  local type_ = M.adapters[scenario.adapter]
  if not type_ or not scenario.label then return nil end
  local config = M.substitute(scenario, vars)
  if not config then return nil end
  config.name, config.type = config.label .. ' (.zed)', type_
  config.label, config.adapter = nil, nil
  config.request = config.request or 'launch'
  config.cwd = config.cwd or root
  if type(config.build) == 'string' then
    -- Zed lets `build` name a task in .zed/tasks.json by its label
    local task = tasks[scenario.build]
    if not task then return nil end
    config.build = M.substitute(task, vars)
    if not config.build then return nil end
  end
  return config
end

local function read_json(path)
  local fd = io.open(path, 'r')
  if not fd then return nil end
  local text = fd:read '*a'
  fd:close()
  local ok, data = pcall(vim.json.decode, M.strip_jsonc(text))
  if not ok then
    vim.notify(('Zed debug: cannot parse %s: %s'):format(path, data), vim.log.levels.ERROR)
    return nil
  end
  return data
end

--- nvim-dap config provider: scenarios from <root>/.zed/debug.json, then Zed's global debug.json.
function M.configs(bufnr)
  local root = vim.fs.root(bufnr, { '.zed', '.git' }) or vim.fn.getcwd()
  local vars = M.variables(bufnr, root)
  local tasks = {}
  for _, task in ipairs(read_json(root .. '/.zed/tasks.json') or {}) do
    if task.label then tasks[task.label] = task end
  end
  local files = {
    root .. '/.zed/debug.json',
    vim.fn.expand '~/Library/Application Support/Zed/debug.json',
    vim.fn.expand '~/.config/zed/debug.json',
  }
  local configs = {}
  for _, path in ipairs(files) do
    for _, scenario in ipairs(read_json(path) or {}) do
      table.insert(configs, M.to_dap(scenario, vars, root, tasks))
    end
  end
  return configs
end

--- Run a Zed `build` ({command, args, cwd, env}) without blocking the UI. Errors on failure.
local function run_build(build, cwd)
  local args = vim.deepcopy(build.args or {})
  -- Zed infers the binary for `cargo build` / `cargo test` when `program` is missing
  local words = vim.split(vim.trim(build.command), '%s+')
  local sub = words[1] == 'cargo' and (words[2] or args[1])
  local locate = sub == 'build' or sub == 'test'
  if locate then
    local dashdash = vim.fn.index(args, '--') -- flags after `--` would go to the test binary
    local at = dashdash >= 0 and dashdash + 1 or #args + 1
    table.insert(args, at, '--message-format=json')
    if sub == 'test' and not vim.tbl_contains(args, '--no-run') then table.insert(args, at, '--no-run') end
  end
  -- Like Zed tasks, the command runs through the shell, so "cargo build" with no args works
  local line = build.command .. ' ' .. table.concat(vim.tbl_map(vim.fn.shellescape, args), ' ')
  vim.notify('Zed debug: building: ' .. line)
  local co = coroutine.running()
  local opts = { cwd = build.cwd or cwd, env = build.env, text = true }
  vim.system({ vim.o.shell, '-c', line }, opts, function(result) vim.schedule(function() coroutine.resume(co, result) end) end)
  local result = coroutine.yield()
  if result.code ~= 0 then error(('Zed debug: build failed (%d):\n%s'):format(result.code, result.stderr), 0) end
  if not locate then return nil end
  local program
  for line in result.stdout:gmatch '[^\n]+' do
    local ok, msg = pcall(vim.json.decode, line)
    if ok and type(msg) == 'table' and msg.reason == 'compiler-artifact' and type(msg.executable) == 'string' then program = msg.executable end
  end
  return program
end

--- nvim-dap on_config hook: runs `build`, fills `program`, routes `tcp_connection`, drops Zed-only keys.
function M.on_config(config)
  if not (config.build or config.tcp_connection) then return config end
  config = vim.deepcopy(config)
  if config.build then
    local program = run_build(config.build, config.cwd)
    config.program = config.program or program
    config.build = nil
  end
  if config.tcp_connection then
    -- Connect to an already running adapter, e.g. `dlv dap --listen=127.0.0.1:53412`
    config.zed_tcp = { host = config.tcp_connection.host or '127.0.0.1', port = config.tcp_connection.port }
    config.type, config.tcp_connection = 'zed-tcp', nil
  end
  return config
end

function M.setup()
  local dap = require 'dap'
  dap.providers.configs['zed.debug.json'] = M.configs
  dap.listeners.on_config['zed-debug'] = M.on_config
  dap.adapters['zed-tcp'] = function(callback, config) callback { type = 'server', host = config.zed_tcp.host, port = config.zed_tcp.port } end
end

return M
