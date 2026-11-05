-- Test runner for Go, Python (pytest) and Rust (cargo test / nextest)
-- https://github.com/nvim-neotest/neotest

vim.pack.add {
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-neotest/neotest',
  { src = 'https://github.com/fredrikaverpil/neotest-golang', version = vim.version.range '*' },
  'https://github.com/nvim-neotest/neotest-python',
}

local neotest = require 'neotest'

---@diagnostic disable-next-line: missing-fields
neotest.setup {
  adapters = {
    require 'neotest-golang' { runner = 'go', go_test_args = { '-v', '-race', '-count=1' } },
    require 'neotest-python' { runner = 'pytest', dap = { justMyCode = false } },
    require 'rustaceanvim.neotest', -- loaded by init.lua before custom.plugins
  },
  status = { virtual_text = true },
  output = { open_on_run = false },
  quickfix = { open = false },
}

local function map(keys, func, desc) vim.keymap.set('n', keys, func, { desc = 'Test: ' .. desc }) end

map('<leader>rt', function() neotest.run.run() end, 'Run nearest [T]est')
map('<leader>rf', function() neotest.run.run(vim.fn.expand '%') end, 'Run [F]ile tests')
map('<leader>ra', function() neotest.run.run(vim.uv.cwd()) end, 'Run [A]ll tests (suite)')
map('<leader>rl', function() neotest.run.run_last() end, 'Re-run [L]ast test')
map('<leader>rd', function() neotest.run.run { strategy = 'dap' } end, '[D]ebug nearest test')
map('<leader>rx', function() neotest.run.stop() end, 'Stop test run')
map('<leader>rw', function() neotest.watch.toggle(vim.fn.expand '%') end, 'Toggle [W]atch file')
map('<leader>rs', function() neotest.summary.toggle() end, 'Toggle test [S]ummary')
map('<leader>ro', function() neotest.output.open { enter = true, auto_close = true } end, 'Show test [O]utput')
map('<leader>rO', function() neotest.output_panel.toggle() end, 'Toggle [O]utput panel')
map(']t', function() neotest.jump.next { status = 'failed' } end, 'Next failed test')
map('[t', function() neotest.jump.prev { status = 'failed' } end, 'Previous failed test')

require('which-key').add { { '<leader>r', group = '[R]un / Test' } }
