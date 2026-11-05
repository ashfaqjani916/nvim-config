-- Local server that previews HTML in the browser and reloads on save (no Node required)
-- https://github.com/brianhuster/live-preview.nvim

vim.pack.add { { src = 'https://github.com/brianhuster/live-preview.nvim', version = vim.version.range '*' } }

vim.keymap.set('n', '<leader>tp', function()
  if require('livepreview').is_running() then
    vim.cmd 'LivePreview close'
  elseif vim.bo.filetype == 'html' then
    vim.cmd 'LivePreview start'
  else
    vim.notify('HTML preview: open an .html file first', vim.log.levels.WARN)
  end
end, { desc = '[T]oggle HTML [P]review server' })
