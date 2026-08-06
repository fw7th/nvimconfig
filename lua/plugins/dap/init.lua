-- ~/.config/nvim/lua/plugins/dap/init.lua
-- Core debugger setup: nvim-dap, dapui, virtual text, and mason-nvim-dap
-- (which auto-installs debug adapters the same way mason-lspconfig auto-
-- installs language servers).
--
-- Language-specific adapters/configurations live in sibling files:
--   lua/dap/cpp.lua        -- codelldb, fed by cmake-tools when available
--   lua/dap/python.lua     -- debugpy
--   lua/dap/typescript.lua -- vscode-js-debug (pwa-node) for TS/JS
-- Rust is handled by rustaceanvim (plugins/rust.lua), not here.
--
-- IMPORTANT lazy.nvim behavior, confirmed against the docs: when the SAME
-- plugin is declared in multiple spec files, `opts`/`dependencies`/`keys`
-- are MERGED across those files, but `config` is NOT -- only the
-- last-loaded config function actually runs; the others are silently
-- discarded. That rules out the "return the same plugin from two files
-- and let lazy merge them" approach for anything that needs a `config`
-- function to run (like our DAP adapter setup).
--
-- So instead of making dap/cpp.lua and dap/python.lua separate lazy specs
-- for "mfussenegger/nvim-dap", they're plain Lua modules (return a table
-- with a `setup()` function, nothing lazy-specific) that THIS file
-- requires and calls explicitly, inside the one real `config` function
-- below. This is the standard, predictable way to split DAP language
-- configs -- LazyVim's own DAP extras use the same pattern.
--
-- cmake-tools.nvim (used by dap/cpp.lua) IS its own separate plugin, so
-- it still gets declared normally as a lazy spec inside cpp.lua -- only
-- the "extend nvim-dap's config" part is done via plain module + explicit
-- require, not via a second lazy spec.

return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "williamboman/mason.nvim",
        "jay-babu/mason-nvim-dap.nvim", -- bridges mason installs -> dap adapters
        "theHamsta/nvim-dap-virtual-text", -- shows variable values inline while debugging
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup()
        require("nvim-dap-virtual-text").setup()

        -- mason-nvim-dap auto-installs adapters. codelldb covers both C++ and
        -- Rust (as a fallback path outside rustaceanvim); debugpy covers
        -- Python; js-debug-adapter covers TypeScript/JavaScript.
        require("mason-nvim-dap").setup({
            ensure_installed = { "codelldb", "debugpy", "js-debug-adapter" },
            automatic_installation = true,
        })

        -- Language-specific adapter/configuration setup (plain modules, see
        -- the note above for why these aren't separate lazy specs).
        require("dap.python").setup()
        require("dap.cpp").setup()
        require("dap.typescript").setup()

        -- Auto open/close dapui alongside debug sessions
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end

        -- Breakpoint signs (visual polish, optional but nice)
        vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
        vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })

        -- Universal DAP keymaps (apply regardless of language).
        -- Language-specific "run debuggables via CMake" style bindings live
        -- in dap/cpp.lua instead, since they're not universal.
        local map = vim.keymap.set
        local opts = { noremap = true, silent = true }

        map("n", "<F1>", dap.continue, vim.tbl_extend("force", opts, { desc = "DAP: Continue/Start" }))
        map("n", "<F2>", dap.step_over, vim.tbl_extend("force", opts, { desc = "DAP: Step Over" }))
        map("n", "<F3>", dap.step_into, vim.tbl_extend("force", opts, { desc = "DAP: Step Into" }))
        map("n", "<S-F3>", dap.step_out, vim.tbl_extend("force", opts, { desc = "DAP: Step Out" }))
        map("n", "<leader>b", dap.toggle_breakpoint, vim.tbl_extend("force", opts, { desc = "DAP: Toggle Breakpoint" }))
        map("n", "<leader>B", function()
            dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, vim.tbl_extend("force", opts, { desc = "DAP: Conditional Breakpoint" }))
        map("n", "<leader>dr", dap.repl.toggle, vim.tbl_extend("force", opts, { desc = "DAP: Toggle REPL" }))
        map("n", "<leader>dl", dap.run_last, vim.tbl_extend("force", opts, { desc = "DAP: Run Last" }))
        map("n", "<leader>dt", dap.terminate, vim.tbl_extend("force", opts, { desc = "DAP: Terminate" }))
        map("n", "<leader>du", dapui.toggle, vim.tbl_extend("force", opts, { desc = "DAP: Toggle UI" })) -- capital-agnostic mnemonic: "dap ui"
    end,
}
