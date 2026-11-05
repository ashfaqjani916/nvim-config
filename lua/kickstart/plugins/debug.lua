-- debug.lua
--
-- Debugger (DAP) for Go (delve), Python (debugpy) and Rust (codelldb via rustaceanvim).
-- Debuggers are installed by mason-tool-installer in init.lua.
-- Works like Zed's debugger: reads .zed/debug.json (lua/custom/zed_debug.lua), uses Zed's
-- default `debugger` settings, and VS Code keys (Zed base_keymap = "VSCode"). See debugging.md.

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/theHamsta/nvim-dap-virtual-text',
  'https://github.com/leoluz/nvim-dap-go',
  'https://github.com/mfussenegger/nvim-dap-python',
}

local dap = require 'dap'
local dapui = require 'dapui'

local function map(keys, func, desc, mode) vim.keymap.set(mode or 'n', keys, func, { desc = 'Debug: ' .. desc }) end

-- F5 picks from .zed/debug.json, .vscode/launch.json and the built-in configs
-- (dap-go, dap-python, and every cargo target rustaceanvim found), or continues a running session
map('<F4>', function() dap.continue { new = true } end, 'Start new session') -- Zed: debugger: start
map('<F5>', dap.continue, 'Start/Continue')
map('<S-F5>', dap.terminate, 'Stop')
map('<F17>', dap.terminate, 'Stop') -- <S-F5> in terminals that send F17
map('<F9>', dap.toggle_breakpoint, 'Toggle Breakpoint')
map('<F10>', dap.step_over, 'Step Over')
map('<F11>', dap.step_into, 'Step Into')
map('<S-F11>', dap.step_out, 'Step Out')
map('<F23>', dap.step_out, 'Step Out') -- <S-F11> in terminals that send F23

map('<leader>dc', dap.continue, '[C]ontinue / start')
map('<leader>db', dap.toggle_breakpoint, 'Toggle [B]reakpoint')
map('<leader>dB', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, 'Conditional [B]reakpoint')
map('<leader>dL', function() dap.set_breakpoint(nil, nil, vim.fn.input 'Log message ({expr} interpolates): ') end, '[L]ogpoint')
map('<leader>dh', function() dap.set_breakpoint(nil, vim.fn.input 'Stop after hit count: ') end, '[H]it-count breakpoint')
map('<leader>do', dap.step_over, 'Step [O]ver')
map('<leader>di', dap.step_into, 'Step [I]nto')
map('<leader>dO', dap.step_out, 'Step [O]ut')
map('<leader>dC', dap.run_to_cursor, 'Run to [C]ursor')
map('<leader>dl', dap.run_last, 'Run [L]ast')
map('<leader>dt', dap.terminate, '[T]erminate')
map('<leader>dr', dap.repl.toggle, 'Toggle [R]EPL')
map('<leader>dx', dap.clear_breakpoints, 'Clear all breakpoints')
map('<leader>du', dapui.toggle, 'Toggle [U]I')
map('<leader>de', dapui.eval, '[E]val expression', { 'n', 'v' })

require('which-key').add { { '<leader>d', group = '[D]ebug', mode = { 'n', 'v' } } }

-- Zed `debugger` defaults: stepping_granularity = "line", dock = "bottom", save_breakpoints = true;
-- inlay_hints.show_value_hints = true is nvim-dap-virtual-text
dap.defaults.fallback.stepping_granularity = 'line'

---@diagnostic disable-next-line: missing-fields
dapui.setup {
  layouts = {
    {
      position = 'bottom',
      size = 14,
      elements = {
        { id = 'scopes', size = 0.3 },
        { id = 'stacks', size = 0.2 },
        { id = 'watches', size = 0.15 },
        { id = 'breakpoints', size = 0.15 },
        { id = 'repl', size = 0.2 },
      },
    },
  },
}
require('nvim-dap-virtual-text').setup {}

-- save_breakpoints: keep breakpoints (with condition / hit count / log message) across restarts
local breakpoints = require 'dap.breakpoints'
local bp_file = vim.fn.stdpath 'state' .. '/dap-breakpoints.json'
local function read_saved()
  local fd = io.open(bp_file, 'r')
  if not fd then return {} end
  local ok, data = pcall(vim.json.decode, fd:read '*a')
  fd:close()
  return ok and type(data) == 'table' and data or {}
end
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('dap-saved-breakpoints', { clear = true }),
  callback = function(ev)
    for _, bp in ipairs(read_saved()[vim.api.nvim_buf_get_name(ev.buf)] or {}) do
      breakpoints.set({ condition = bp.condition, hit_condition = bp.hitCondition, log_message = bp.logMessage }, ev.buf, bp.line)
    end
  end,
})
vim.api.nvim_create_autocmd('VimLeavePre', {
  group = 'dap-saved-breakpoints',
  callback = function()
    local saved, current = read_saved(), breakpoints.get()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(buf)
      -- only files loaded this session are rewritten; others keep their saved breakpoints
      if name ~= '' and vim.api.nvim_buf_is_loaded(buf) then
        saved[name] = current[buf] and vim.tbl_map(function(bp) return { line = bp.line, condition = bp.condition, hitCondition = bp.hitCondition, logMessage = bp.logMessage } end, current[buf])
      end
    end
    local fd = io.open(bp_file, 'w')
    if fd then
      fd:write(vim.json.encode(saved))
      fd:close()
    end
  end,
})

vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#ff4331' })
vim.api.nvim_set_hl(0, 'DapStop', { fg = '#f79d3b' })
vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#33231b' })
local breakpoint_icons = { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
for type, icon in pairs(breakpoint_icons) do
  local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
  vim.fn.sign_define('Dap' .. type, { text = icon, texthl = hl, numhl = hl, linehl = type == 'Stopped' and 'DapStoppedLine' or nil })
end

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- Go: debug file / package / nearest test (`dlv` from Mason)
require('dap-go').setup {
  delve = {
    -- On Windows delve must be run attached or it crashes.
    detached = vim.fn.has 'win32' == 0,
  },
}

-- Python: adapter from Mason's debugpy; the debuggee runs on the project's venv
-- (VIRTUAL_ENV, CONDA_PREFIX, or ./venv, ./.venv), falling back to python3
require('dap-python').setup 'debugpy-adapter'

-- .zed/debug.json scenarios (Delve / Debugpy / CodeLLDB), shared with Zed
require('custom.zed_debug').setup()
