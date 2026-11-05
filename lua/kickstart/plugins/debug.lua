-- debug.lua
--
-- Debugger (DAP) for Go (delve), Python (debugpy) and Rust (codelldb via rustaceanvim).
-- Debuggers are installed by mason-tool-installer in init.lua.
-- Keys follow VS Code (Zed base_keymap = "VSCode"), with <leader>d* fallbacks.

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

-- Rust: rustaceanvim's :RustLsp debuggables picks the binary/test; everything else uses dap.continue
local function start_or_continue()
  if vim.bo.filetype == 'rust' and not dap.session() then
    vim.cmd.RustLsp 'debuggables'
  else
    dap.continue()
  end
end

map('<F5>', start_or_continue, 'Start/Continue')
map('<S-F5>', dap.terminate, 'Stop')
map('<F17>', dap.terminate, 'Stop') -- <S-F5> in terminals that send F17
map('<F9>', dap.toggle_breakpoint, 'Toggle Breakpoint')
map('<F10>', dap.step_over, 'Step Over')
map('<F11>', dap.step_into, 'Step Into')
map('<S-F11>', dap.step_out, 'Step Out')
map('<F23>', dap.step_out, 'Step Out') -- <S-F11> in terminals that send F23

map('<leader>dc', start_or_continue, '[C]ontinue / start')
map('<leader>db', dap.toggle_breakpoint, 'Toggle [B]reakpoint')
map('<leader>dB', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, 'Conditional [B]reakpoint')
map('<leader>dL', function() dap.set_breakpoint(nil, nil, vim.fn.input 'Log message: ') end, '[L]ogpoint')
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

---@diagnostic disable-next-line: missing-fields
dapui.setup {}
require('nvim-dap-virtual-text').setup {}

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
