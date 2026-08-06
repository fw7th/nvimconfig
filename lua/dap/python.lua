-- ~/.config/nvim/lua/dap/python.lua
-- Plain Lua module -- NOT a lazy.nvim plugin spec (see the note at the top
-- of dap/cpp.lua for why). Called via require("dap.python").setup() from
-- plugins/dap/init.lua.

local M = {}

function M.setup()
    local dap = require("dap")
    local mason_registry = require("mason-registry")

    local debugpy_root = mason_registry.is_installed("debugpy")
        and mason_registry.get_package("debugpy"):get_install_path()
        or (vim.fn.stdpath("data") .. "/mason/packages/debugpy")

    dap.adapters.python = {
        type = "executable",
        command = debugpy_root .. "/venv/bin/python",
        args = { "-m", "debugpy.adapter" },
    }

    dap.configurations.python = {
        {
            type = "python",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            pythonPath = function()
                -- Prefer an active venv if one exists, else fall back to python3
                local venv = os.getenv("VIRTUAL_ENV")
                if venv then
                    return venv .. "/bin/python"
                end
                return "/usr/bin/python3"
            end,
        },
    }
end

return M
