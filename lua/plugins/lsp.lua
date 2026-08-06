-- LSP servers, installed/managed via Mason.
-- rust_analyzer is handled separately by rustaceanvim (see plugins/rust.lua),
-- so it's intentionally NOT in ensure_installed here.

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = { "pyright", "ruff", "clangd", "ts_ls" },
            automatic_installation = true,
        })

        local lspconfig = require("lspconfig")

        -- Common on_attach: keymaps applied to every LSP-attached buffer
        local on_attach = function(_, bufnr)
            local opts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>f", function()
                vim.lsp.buf.format({ async = true })
            end, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
            vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
        end

        -- Pyright: type checking and intelligent completions
        vim.lsp.config("pyright", {
            on_attach = on_attach,
            settings = {
                python = {
                    analysis = {
                        typeCheckingMode = "basic",
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = "workspace",
                        -- extraPaths = {}, -- ROS2 paths
                    },
                },
            },
        })

        -- Ruff: fast linting/formatting (replaces ruff_lsp). Hover disabled
        -- in favor of Pyright's richer hover.
        vim.lsp.config("ruff", {
            on_attach = function(client, bufnr)
                client.server_capabilities.hoverProvider = false
                on_attach(client, bufnr)
            end,
        })

        -- clangd: C/C++
        vim.lsp.config("clangd", {
            on_attach = on_attach,
        })

        -- ts_ls: TypeScript/JavaScript. Formatting is disabled here in favor
        -- of conform.nvim + prettier (see plugins/conform.lua), same pattern
        -- as Ruff being preferred over Pyright's formatter.
        vim.lsp.config("ts_ls", {
            on_attach = function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
                on_attach(client, bufnr)
            end,
        })
    end,
}
