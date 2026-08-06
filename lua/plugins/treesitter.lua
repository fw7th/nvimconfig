return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "python", "lua", "json", "yaml", "toml", "markdown", "xml",
                -- C/C++/Rust:
                "c", "cpp", "rust", "cmake",
                -- TypeScript/JavaScript:
                "typescript", "tsx", "javascript",
            },
            highlight = { enable = true },
            indent = { enable = true },
        })
    end,
}
