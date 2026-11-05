-- Render Markdown in the buffer (headings, code blocks, tables, checkboxes)
-- https://github.com/MeanderingProgrammer/render-markdown.nvim

vim.pack.add { { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim', version = vim.version.range '*' } }

require('render-markdown').setup {}

vim.keymap.set('n', '<leader>tm', function()
  vim.cmd 'RenderMarkdown toggle'
  -- Redraw or clear images right away instead of on the next scroll/edit
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.b[buf].snacks_image_attached then vim.api.nvim_exec_autocmds('BufWinEnter', { group = 'snacks.image.inline.' .. buf, buffer = buf }) end
  end
end, { desc = '[T]oggle [M]arkdown preview' })

-- Images and Mermaid diagrams drawn inline in the terminal (kitty graphics protocol, e.g. Ghostty)
-- Needs `magick` (ImageMagick) and, for Mermaid, `mmdc` (npm i -g @mermaid-js/mermaid-cli)
-- https://github.com/folke/snacks.nvim/blob/main/docs/image.md
vim.pack.add { { src = 'https://github.com/folke/snacks.nvim', version = vim.version.range '*' } }

-- Markdown only: don't open image files as images, and don't attach to other filetypes (html, css, ...)
require('snacks').setup { image = { formats = {}, doc = { enabled = false } } }

-- Only draw images while the Markdown preview is on. snacks has no off switch, so this
-- hooks the lookup its inline renderer calls on every update (snacks/image/inline.lua).
local find_visible = Snacks.image.doc.find_visible
Snacks.image.doc.find_visible = function(buf, cb)
  if not require('render-markdown').get() then return cb {} end
  return find_visible(buf, cb)
end

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Draw images and Mermaid diagrams in Markdown buffers',
  group = vim.api.nvim_create_augroup('custom-markdown-images', { clear = true }),
  pattern = 'markdown',
  callback = function(ev) Snacks.image.doc.attach(ev.buf) end,
})
