-- ~/.config/nvim/lua/plugins/dap/cmake.lua
-- cmake-tools.nvim: generates/builds CMake projects and can hand the
-- resolved target executable to nvim-dap, so you don't hand-type a path
-- to your binary every time you want to debug.
--
-- This IS a real plugin (unlike lua/dap/cpp.lua, which is a plain module),
-- so it lives here in the auto-scanned lua/plugins/ tree normally.
--
-- Division of responsibility:
--   this file       -- declares the plugin, its own setup(), and CMake
--                       workflow keymaps (generate/build/run/select target)
--   lua/dap/cpp.lua -- registers the codelldb DAP adapter and reads back
--                       whatever target this plugin resolved

return {
    "Civitasv/cmake-tools.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
        require("cmake-tools").setup({
            cmake_dap_configuration = { -- tells cmake-tools which dap adapter/type to hand targets to
                name = "cpp",
                type = "codelldb",
                request = "launch",
            },
        })
    end,
    keys = {
        { "<leader>cg", "<cmd>CMakeGenerate<CR>",           desc = "CMake: Generate" },
        { "<leader>cb", "<cmd>CMakeBuild<CR>",              desc = "CMake: Build" },
        { "<leader>cr", "<cmd>CMakeRun<CR>",                desc = "CMake: Run" },
        { "<leader>cd", "<cmd>CMakeDebug<CR>",              desc = "CMake: Debug (launches DAP directly)" },
        { "<leader>ct", "<cmd>CMakeSelectLaunchTarget<CR>", desc = "CMake: Select Launch Target" },
        { "<leader>cc", "<cmd>CMakeClean<CR>",              desc = "CMake: Clean" },
    },
}
