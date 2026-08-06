-- ~/.config/nvim/lua/config/keymaps.lua
-- Keymaps that don't belong to a specific plugin.
-- Plugin-specific keymaps live next to that plugin's spec in lua/plugins/.

local map = vim.keymap.set

-- Save shortcuts
map("n", "<C-s>", ":w<CR>", { desc = "Save File", noremap = true, silent = true })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save File (Insert)", noremap = true, silent = true })

-- Terminal escape
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode", noremap = true, silent = true })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window Left", noremap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Window Down", noremap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Window Up", noremap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Window Right", noremap = true })
