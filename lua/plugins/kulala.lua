return {
    "mistweaverco/kulala.nvim",
    config = function()
        require("kulala").setup()
    end,
    keys = {
        { "<leader>rr", function() require("kulala").run() end,     desc = "Run HTTP Request" },
        { "<leader>ra", function() require("kulala").run_all() end, desc = "Run All HTTP Requests" },
        { "<leader>ri", function() require("kulala").inspect() end, desc = "Inspect HTTP Request" },
        { "<leader>rc", function() require("kulala").copy() end,    desc = "Copy HTTP Request as cURL" },
    },
}
