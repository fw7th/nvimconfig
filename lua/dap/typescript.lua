-- ~/.config/nvim/lua/dap/typescript.lua
-- Plain Lua module -- NOT a lazy.nvim plugin spec (same reasoning as
-- dap/cpp.lua and dap/python.lua: config functions don't merge across
-- lazy specs, so language setup is centralized and called explicitly
-- from plugins/dap/init.lua).
--
-- Uses vscode-js-debug (mason package name: js-debug-adapter), the same
-- debug adapter VS Code itself uses for Node.js/TypeScript. Handles both
-- plain Node scripts and ts-node/tsx-run TypeScript directly.

local M = {}

function M.setup()
    local dap = require("dap")
    local mason_registry = require("mason-registry")

    local js_debug_root = mason_registry.is_installed("js-debug-adapter")
        and mason_registry.get_package("js-debug-adapter"):get_install_path()
        or (vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter")

    dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
            command = "node",
            args = { js_debug_root .. "/js-debug/src/dapDebugServer.js", "${port}" },
        },
    }

    local js_like_languages = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

    for _, lang in ipairs(js_like_languages) do
        dap.configurations[lang] = {
            {
                type = "pwa-node",
                request = "launch",
                name = "Launch file (node)",
                program = "${file}",
                cwd = "${workspaceFolder}",
                -- Lets Node resolve .ts files directly without a separate
                -- compile step, as long as ts-node is a project dependency.
                runtimeArgs = { "-r", "ts-node/register" },
                skipFiles = { "<node_internals>/**" },
                resolveSourceMapLocations = {
                    "${workspaceFolder}/**",
                    "!**/node_modules/**",
                },
            },
            {
                type = "pwa-node",
                request = "attach",
                name = "Attach to running process",
                processId = require("dap.utils").pick_process,
                cwd = "${workspaceFolder}",
                skipFiles = { "<node_internals>/**" },
            },
        }
    end
end

return M
