-- ~/.config/nvim/lua/config/options.lua
-- Core editor settings (vim.opt).

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- UI
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.shortmess:append("I") -- disable intro message

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- System integration
opt.clipboard = "unnamedplus"
opt.mouse = "a"

-- Behavior
opt.updatetime = 250
opt.undofile = true
opt.swapfile = false
opt.completeopt = "menu,menuone,noselect"
opt.formatoptions:remove({ "c", "r", "o" }) -- don't auto-continue comments

-- Diagnostics (LSP)
vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})
