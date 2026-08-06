return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-python",
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-python")({
                    dap = { justMyCode = false },
                    args = { "--log-level", "DEBUG" },
                    runner = "pytest",
                }),
            },
        })
    end,
    keys = {
        { "<leader>tt", function() require("neotest").run.run() end,                              desc = "Run Nearest Test" },
        { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end,             desc = "Run Test File" },
        { "<leader>ts", function() require("neotest").summary.toggle() end,                        desc = "Toggle Test Summary" },
        { "<leader>to", function() require("neotest").output.open({ enter = true }) end,           desc = "Show Test Output" },
    },
}
