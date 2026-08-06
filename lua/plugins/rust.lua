-- rustaceanvim bundles its own LSP setup (rust-analyzer) AND its own DAP
-- integration (it wires codelldb up for you automatically when you run
-- :RustLsp debuggables). That's why rust_analyzer is deliberately absent
-- from mason-lspconfig's ensure_installed in plugins/lsp.lua -- this
-- plugin owns Rust's LSP lifecycle entirely; running it alongside a
-- manually-configured rust_analyzer causes duplicate-server conflicts.

return {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false, -- ft-based lazy loading is handled internally by the plugin
    keys = {
        { "<leader>rd", function() vim.cmd.RustLsp("debuggables") end, desc = "Rust: Debuggables (DAP)" },
    },
}
