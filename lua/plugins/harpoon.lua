-- NOTE on a bug in your old config: <C-e> was bound TWICE (once to a custom
-- telescope-picker function, once to harpoon's built-in quick menu). The
-- second vim.keymap.set call silently overwrote the first, so the telescope
-- picker function below was dead code. Keeping the built-in quick menu
-- (simpler, maintained by harpoon itself) and dropping the duplicate.
-- If you actually want the telescope picker UI back, tell me and I'll
-- rebind it to a different key (e.g. <leader>he).

return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup({})

        local map = vim.keymap.set
        map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: Add File" })
        map("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
            { desc = "Harpoon: Toggle Quick Menu" })

        map("n", "<C-p>", function() harpoon:list():select(1) end, { desc = "Harpoon: Select 1" })
        map("n", "<C-t>", function() harpoon:list():select(2) end, { desc = "Harpoon: Select 2" })
        map("n", "<C-i>", function() harpoon:list():select(3) end, { desc = "Harpoon: Select 3" })
        map("n", "<C-y>", function() harpoon:list():select(4) end, { desc = "Harpoon: Select 4" })

        map("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = "Harpoon: Previous" })
        map("n", "<C-o>", function() harpoon:list():next() end, { desc = "Harpoon: Next" })
    end,
}
