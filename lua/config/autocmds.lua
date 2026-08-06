-- ~/.config/nvim/lua/config/autocmds.lua

-- Python-specific indentation (redundant with global opts but explicit is fine —
-- protects you if global tabstop/shiftwidth ever changes for other filetypes)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Prevent comment continuation globally (belt-and-suspenders alongside
-- the formatoptions:remove in options.lua — some plugins/filetypes reset this)
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})
