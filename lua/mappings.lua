require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")          edit this file

-- Add comment/uncomment mappings for Go files
local go_comment_opts = { buffer = true, silent = true } -- Apply only to current buffer
map("v", "<leader>gc", ":s/^/\\/\\//<CR>", go_comment_opts)
map("v", "<leader>gu", ":s/^\\/\\/\\s*//<CR>", go_comment_opts)

-- Editing the mappings.lua file itself:
map("n", "<leader>em", "<cmd>edit ~/.config/nvim/lua/custom/mappings.lua<CR>", { desc = "Edit mappings.lua" })

-- Example of a filetype specific mapping.
--map("n", "<leader>go", "<cmd>GoBuild<CR>", { buffer = true, desc = "Go Build", callback = function() if vim.bo.filetype == "go" then return true else return false end})
