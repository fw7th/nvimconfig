-- ~/.config/nvim/lua/dap/cpp.lua
-- Plain Lua module -- NOT a lazy.nvim plugin spec. Deliberately placed
-- outside lua/plugins/ so lazy's auto-scanner (lua/plugins/**) never sees
-- it and tries to interpret it as a plugin.
--
-- Called explicitly from plugins/dap/init.lua's config function via
-- require("dap.cpp").setup(). See that file for why: lazy.nvim doesn't
-- merge `config` functions across multiple specs for the same plugin, so
-- language-specific DAP setup has to be plain functions called from one
-- single place, not separate lazy specs.
--
-- The actual cmake-tools.nvim PLUGIN declaration (dependencies, keys, its
-- own setup()) lives in plugins/dap/cmake.lua -- that one's a real plugin
-- so it belongs in the auto-scanned tree. This file only registers the
-- codelldb DAP adapter/configurations and reads the target cmake-tools
-- resolved, it doesn't declare cmake-tools as a dependency itself.

local M = {}

function M.setup()
    local dap = require("dap")

    ---------------------------------------------------------------------
    -- codelldb adapter
    ---------------------------------------------------------------------
    -- mason installs codelldb to a predictable path under mason's install
    -- root. mason-nvim-dap (plugins/dap/init.lua) ensures it's installed;
    -- here we just point dap at the binary.
    local mason_registry = require("mason-registry")
    local codelldb_root = mason_registry.is_installed("codelldb")
        and mason_registry.get_package("codelldb"):get_install_path()
        or (vim.fn.stdpath("data") .. "/mason/packages/codelldb")

    local codelldb_path = codelldb_root .. "/extension/adapter/codelldb"
    local liblldb_path = codelldb_root .. "/extension/lldb/lib/liblldb.so"

    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = codelldb_path,
            args = { "--port", "${port}", "--liblldb", liblldb_path },
        },
    }

    ---------------------------------------------------------------------
    -- Launch configurations
    ---------------------------------------------------------------------
    -- Two entries:
    --   1. "Debug via CMake" -- uses cmake-tools' currently selected
    --      target/executable. This is the one you'll use most of the time
    --      once a CMake project is configured (see plugins/dap/cmake.lua
    --      for the <leader>c* keymaps that drive target selection/build).
    --   2. "Launch file (manual path)" -- your original fallback, for
    --      quick one-off binaries with no CMake project.
    --
    -- NOTE: cmake-tools.nvim's Lua API for pulling the resolved launch
    -- target path has shifted across versions (the plugin is under active
    -- development). `pcall` + a nil check means if the API doesn't match
    -- what's called here, you get the manual path prompt instead of an
    -- error. Verify against your installed version with
    -- :lua print(vim.inspect(require("cmake-tools")))
    -- and adjust cmake_dap() below if the function name differs.
    local function cmake_dap_target()
        local ok, cmake = pcall(require, "cmake-tools")
        if not ok then
            return nil
        end
        local get_target = cmake.get_launch_target or cmake.get_launch_path
        if not get_target then
            return nil
        end
        local ok2, target = pcall(get_target)
        if ok2 and target and target ~= "" then
            return target
        end
        return nil
    end

    dap.configurations.cpp = {
        {
            name = "Debug via CMake (current target)",
            type = "codelldb",
            request = "launch",
            program = function()
                local target = cmake_dap_target()
                if target then
                    return target
                end
                vim.notify(
                    "No CMake target resolved -- run :CMakeSelectLaunchTarget first, or use 'Launch file (manual path)'.",
                    vim.log.levels.WARN)
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
        {
            name = "Launch file (manual path)",
            type = "codelldb",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
    }
    dap.configurations.c = dap.configurations.cpp
end

return M
