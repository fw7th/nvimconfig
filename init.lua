-- ~/.config/nvim/init.lua
-- Entry point. Keep this file tiny — everything else lives under lua/config and lua/plugins.

-- Leader key MUST be set before lazy.nvim loads any plugins that reference <leader>
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Core config (order matters: options -> plugins -> keymaps/autocmds)
require("config.options")

-- lazy.nvim auto-discovers every file (and subfolder) under lua/plugins/
-- as long as each one returns a plugin spec table.
require("lazy").setup("plugins")

require("config.keymaps")
require("config.autocmds")
require("config.terminal")
