return {
    "stevearc/conform.nvim",
    dependencies = {
        "williamboman/mason.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim", -- auto-installs non-LSP tools (formatters, linters)
    },
    config = function()
        -- prettier and clang-format aren't LSP servers, so they don't go
        -- through mason-lspconfig (plugins/lsp.lua) -- mason-tool-installer
        -- covers this category instead, same auto-install philosophy.
        require("mason-tool-installer").setup({
            ensure_installed = { "prettier", "clang-format" },
        })

        require("conform").setup({
            formatters_by_ft = {
                python = { "ruff_format", "ruff_organize_imports" },
                typescript = { "prettier" },
                typescriptreact = { "prettier" },
                javascript = { "prettier" },
                javascriptreact = { "prettier" },
                cpp = { "clang_format" },
                c = { "clang_format" },
                -- Rust isn't listed here on purpose: rustaceanvim wires
                -- rustfmt in through rust-analyzer's own formatting request
                -- (triggered by the <leader>f keymap same as everything
                -- else), so conform doesn't need to own it.
            },
            -- clang_format needs no custom setup here: conform's built-in
            -- clang_format formatter automatically picks up a project's
            -- .clang-format file if one exists in the file's directory tree,
            -- and falls back to clang-format's own default (LLVM) style if
            -- none is found. Same auto-detection behavior as ruff_format for
            -- Python and prettier for TS/JS -- project config wins, no
            -- config here overrides it.
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        })
    end,
}
