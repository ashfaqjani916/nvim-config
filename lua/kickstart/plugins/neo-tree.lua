-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })
vim.keymap.set('n', '<leader>e', '<Cmd>Neotree toggle reveal<CR>', { desc = 'File [E]xplorer', silent = true })

-- Mirrors Zed's project_panel: docked right, git status + diagnostics badges, gitignored files shown
require('neo-tree').setup {
  close_if_last_window = true,
  enable_git_status = true,
  enable_diagnostics = true,
  window = {
    position = 'right',
    width = 34,
    mappings = {
      ['<CR>'] = 'open',
      ['O'] = 'open_split',
      ['P'] = 'open_vsplit',
    },
  },
  filesystem = {
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
    filtered_items = {
      visible = true, -- show hidden/gitignored files, dimmed
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}
