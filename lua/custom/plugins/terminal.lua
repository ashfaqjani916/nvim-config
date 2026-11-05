-- Bottom terminals (Zed: terminal dock = bottom), lazygit, and "run this project"
-- Uses snacks.nvim (already installed for markdown images) — no extra plugin.
-- https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md

vim.pack.add { { src = 'https://github.com/folke/snacks.nvim', version = vim.version.range '*' } }
require 'snacks'

local bottom = { win = { position = 'bottom', height = 0.3 } }

-- Count picks the terminal: <C-/> is terminal 1, 2<C-/> is terminal 2, ...
local function toggle_term() Snacks.terminal.toggle(nil, vim.tbl_extend('force', bottom, { count = vim.v.count1 })) end

-- A new terminal with the next free number
local function new_term()
  local used = {}
  for _, term in ipairs(Snacks.terminal.list()) do
    local id = vim.b[term.buf].snacks_terminal
    if id then used[id.id] = true end
  end
  local n = 1
  while used[n] do
    n = n + 1
  end
  Snacks.terminal.open(nil, vim.tbl_extend('force', bottom, { count = n }))
end

-- Run the current project/file in a bottom terminal that stays open
local run_cmd = {
  go = 'go run .',
  python = function(file) return 'python3 ' .. vim.fn.shellescape(file) end,
  rust = 'cargo run',
}
local function run_project()
  local cmd = run_cmd[vim.bo.filetype]
  if not cmd then return vim.notify('Run: no runner for filetype ' .. vim.bo.filetype, vim.log.levels.WARN) end
  if type(cmd) == 'function' then cmd = cmd(vim.api.nvim_buf_get_name(0)) end
  vim.cmd 'silent! wall'
  Snacks.terminal.open(cmd, vim.tbl_deep_extend('force', bottom, { cwd = vim.fn.expand '%:p:h', interactive = false, auto_close = false }))
end

-- <C-/> is sent as <C-_> by many terminals; <C-`> mirrors VS Code/Zed where the terminal supports it
for _, key in ipairs { '<C-/>', '<C-_>', '<C-`>' } do
  vim.keymap.set({ 'n', 't' }, key, toggle_term, { desc = 'Toggle bottom terminal ([count] picks which)' })
end
vim.keymap.set('n', '<leader>tt', toggle_term, { desc = '[T]oggle [T]erminal ([count] picks which)' })
vim.keymap.set('n', '<leader>tn', new_term, { desc = '[T]erminal: [N]ew' })
vim.keymap.set('n', '<leader>rr', run_project, { desc = '[R]un project / file' })
vim.keymap.set('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Lazy[G]it' })

require('which-key').add { { '<leader>g', group = '[G]it' } }
