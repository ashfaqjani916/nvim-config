-- Cinder Peak: the Rex terminal theme (Rex.app themes.json, id "cinder-peak"), as rendered on screen.
-- Built on mini.base16, so every plugin highlight group gets a sensible color.
vim.o.background = 'dark'
vim.g.colors_name = nil

require('mini.base16').setup {
  palette = {
    base00 = '#151011', -- background (canvas)
    base01 = '#1c1718', -- statusline, cursorline, floats (surfaceSubtle)
    base02 = '#46252a', -- selection
    base03 = '#746866', -- comments, line numbers (contentTertiary)
    base04 = '#928581', -- dark foreground (contentSecondary)
    base05 = '#deccc5', -- foreground
    base06 = '#f3e7e2',
    base07 = '#f3e7e2',
    base08 = '#ff4331', -- red
    base09 = '#ff5021', -- accent orange (cursor)
    base0A = '#f79d3b', -- yellow
    base0B = '#96ae6e', -- green
    base0C = '#8cb3a8', -- cyan
    base0D = '#9188c6', -- blue/violet
    base0E = '#db7493', -- magenta
    base0F = '#c0b0ab',
  },
  use_cterm = true,
}

-- Embedded terminals use exactly Rex's ANSI colors
local ansi = {
  '#231a1b', '#ff4331', '#96ae6e', '#f79d3b', '#9188c6', '#db7493', '#8cb3a8', '#c0b0ab',
  '#6d5a58', '#ff6d51', '#b0c68a', '#ffb552', '#aba3d8', '#ee90ab', '#a7cbbf', '#f3e7e2',
}
for i, color in ipairs(ansi) do
  vim.g['terminal_color_' .. (i - 1)] = color
end

vim.api.nvim_set_hl(0, 'Cursor', { fg = '#151011', bg = '#ff5021' })
vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#383030' })

vim.g.colors_name = 'cinder-peak'
