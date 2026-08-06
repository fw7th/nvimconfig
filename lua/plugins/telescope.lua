return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("telescope").setup({
            defaults = {
                file_ignore_patterns = {
                    "node_modules", ".git/", "__pycache__",
                    ".pytest_cache/", ".venv/", "venv/",
                    ".mypy_cache/", ".ruff_cache/", "*.egg-info/",
                    "build/", "cmake%-build%-.*/",
                },
            },
        })
    end,
    keys = {
        { "<C-f>", ":Telescope find_files<CR>", desc = "Find Files" },
        { "<C-g>", ":Telescope live_grep<CR>",  desc = "Live Grep" },
    },
}
