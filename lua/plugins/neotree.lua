return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        require("neo-tree").setup({
            close_if_last_window = true,
            filesystem = {
                follow_current_file = { enabled = true },
                filtered_items = {
                    visible = false,
                    hide_dotfiles = true,
                    hide_gitignored = true,
                    hide_by_name = {
                        ".git",
                        ".DS_Store",
                        "thumbs.db",
                        "node_modules",
                        "__pycache__",
                        ".pytest_cache",
                        ".venv",
                        "venv",
                        ".mypy_cache",
                        ".ruff_cache",
                        "*.egg-info",
                        -- Added for C++/CMake workflows:
                        "build",
                        "cmake-build-debug",
                        "cmake-build-release",
                    },
                },
            },
            window = { width = 30 },
        })
    end,
    keys = {
        { "<C-n>", ":Neotree toggle<CR>", desc = "Toggle Neo-tree" },
    },
}
