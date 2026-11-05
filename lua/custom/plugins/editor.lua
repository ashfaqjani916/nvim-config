-- Zed-inspired editor chrome: sticky scroll and an outline panel docked left

-- Sticky scroll (Zed: sticky_scroll.enabled)
-- https://github.com/nvim-treesitter/nvim-treesitter-context
vim.pack.add { 'https://github.com/nvim-treesitter/nvim-treesitter-context' }
require('treesitter-context').setup { max_lines = 3 }

-- Symbol outline (Zed: outline_panel.dock = left)
-- https://github.com/stevearc/aerial.nvim
vim.pack.add { 'https://github.com/stevearc/aerial.nvim' }
require('aerial').setup {
  backends = { 'lsp', 'treesitter' },
  layout = { default_direction = 'left', placement = 'edge', min_width = 28 },
  attach_mode = 'global',
}
vim.keymap.set('n', '<leader>o', '<Cmd>AerialToggle<CR>', { desc = '[O]utline panel' })
