-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.cursorline = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 8
vim.opt.mouse = "a"
vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.formatoptions:remove({ "c", "r", "o" })

-- Disable the Neovim intro message
vim.opt.shortmess:append("I")

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

require("lazy").setup({
    -- Colorscheme
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "night",
                transparent = false,
            })
            vim.cmd [[colorscheme tokyonight-night]]
        end
    },

    -- LSP Config
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "pyright", "ruff" },
                automatic_installation = true,
            })

            local lspconfig = require("lspconfig")

            -- Common on_attach function for keymaps
            local on_attach = function(client, bufnr)
                local opts = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', '<leader>f', function()
                    vim.lsp.buf.format({ async = true })
                end, opts)
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
                vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
            end

            -- Pyright for type checking and intelligent completions
            lspconfig.pyright.setup({
                on_attach = on_attach,
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = "workspace",
                        }
                    }
                }
            })

            -- Ruff for fast linting and formatting (replaces ruff_lsp)
            lspconfig.ruff.setup({
                on_attach = function(client, bufnr)
                    -- Disable hover in favor of Pyright
                    client.server_capabilities.hoverProvider = false
                    on_attach(client, bufnr)
                end,
            })
        end
    },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }, {
                    { name = 'buffer' },
                    { name = 'path' },
                })
            })
        end
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "python", "lua", "json", "yaml", "toml", "markdown" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

    -- File Tree
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                close_if_last_window = true,
                filesystem = {
                    follow_current_file = { enabled = true },
                    filtered_items = {
                        visible = false,
                        hide_dotfiles = true,
                        hide_gitignored = true,
                        hide_by_name = {
                            ".git",
                            ".DS_Store",
                            "thumbs.db",
                            "node_modules",
                            "__pycache__",
                            ".pytest_cache",
                            ".venv",
                            "venv",
                            ".mypy_cache",
                            ".ruff_cache",
                            "*.egg-info",
                        },
                    },
                },
                window = { width = 30 },
            })
        end
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    file_ignore_patterns = {
                        "node_modules", ".git/", "__pycache__",
                        ".pytest_cache/", ".venv/", "venv/",
                        ".mypy_cache/", ".ruff_cache/", "*.egg-info/"
                    },
                },
            })
        end
    },

    -- Formatting
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    python = { "ruff_format", "ruff_organize_imports" },
                },
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
            })
        end
    },

    -- Test Runner (nvim-neotest)
    {
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
                    })
                }
            })
        end
    },

    -- HTTP Client for API testing
    {
        "mistweaverco/kulala.nvim",
        config = function()
            require("kulala").setup()
        end
    },

    -- Git integration
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end
    },

    -- Comment plugin
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end
    },

    -- Auto-pairs
    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup()
        end
    },
})

-- Terminal state variables
local term_buf = nil
local term_win = nil

-- Run FastAPI Development Server
function RunFastAPI()
    vim.cmd('write') -- Save current file

    -- First: capture and set CWD before creating terminal
    local current_cwd = vim.fn.expand("%:p:h")
    if current_cwd ~= nil and current_cwd ~= "" then
        vim.cmd('lcd ' .. current_cwd)
    else
        vim.notify("Invalid buffer path; cannot set working directory.", vim.log.levels.WARN)
        return
    end

    -- Close existing terminal if open
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
    end

    -- Create new terminal
    vim.cmd('botright 15new')
    vim.cmd('term')

    term_win              = vim.api.nvim_get_current_win()
    term_buf              = vim.api.nvim_get_current_buf()
    vim.wo.number         = false
    vim.wo.relativenumber = false

    -- Build full paths
    local main_file_path  = vim.fs.joinpath(current_cwd, "main.py")
    local app_file_path   = vim.fs.joinpath(current_cwd, "app.py")

    -- Try to find main.py or app.py
    local main_file       = nil
    if vim.fn.filereadable(main_file_path) == 1 then
        main_file = main_file_path
    elseif vim.fn.filereadable(app_file_path) == 1 then
        main_file = app_file_path
    else
        vim.notify("Neither main.py nor app.py found in the current directory", vim.log.levels.ERROR)
        return
    end

    -- Run uvicorn (this part still uses just the filename)
    local job_id = vim.b.terminal_job_id
    if not job_id then
        vim.notify("No terminal job found", vim.log.levels.ERROR)
        return
    end

    -- Send uvicorn run command to terminal
    local module_name = main_file:gsub(".*/", ""):gsub("%.py$", "")
    vim.api.nvim_chan_send(job_id,
        string.format('clear && uvicorn %s:app --reload --host 0.0.0.0 --port 8000\n', module_name))
end

-- Run Python Script
function RunPython()
    local file = vim.fn.expand('%:p')
    vim.cmd('write')

    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
    end

    vim.cmd('botright 15new')
    vim.cmd('term')

    term_win = vim.api.nvim_get_current_win()
    term_buf = vim.api.nvim_get_current_buf()

    vim.wo.number = false
    vim.wo.relativenumber = false

    vim.api.nvim_chan_send(vim.b.terminal_job_id,
        string.format('clear && python3 "%s"\n', file))
end

-- Run Pytest
function RunPytest()
    vim.cmd('write')

    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
    end

    vim.cmd('botright 15new')
    vim.cmd('term')

    term_win = vim.api.nvim_get_current_win()
    term_buf = vim.api.nvim_get_current_buf()

    vim.wo.number = false
    vim.wo.relativenumber = false

    vim.api.nvim_chan_send(vim.b.terminal_job_id, 'clear && pytest -v\n')
end

-- Terminal Toggle Function
function ToggleTerminal()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
        term_win = nil
        term_buf = nil
    else
        vim.cmd('botright 15new')
        vim.cmd('term')
        term_win = vim.api.nvim_get_current_win()
        term_buf = vim.api.nvim_get_current_buf()
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.cmd('startinsert')
    end
end

-- Keymaps
vim.keymap.set('n', '<F5>', RunPython, { desc = "Run Python Script", noremap = true, silent = true })
vim.keymap.set('n', '<F6>', RunFastAPI, { desc = "Run FastAPI Server", noremap = true, silent = true })
vim.keymap.set('n', '<F7>', RunPytest, { desc = "Run Pytest", noremap = true, silent = true })
vim.keymap.set('n', '<F4>', ToggleTerminal, { desc = "Toggle Terminal", noremap = true, silent = true })
vim.keymap.set('t', '<F4>', '<C-\\><C-n>:lua ToggleTerminal()<CR>',
    { desc = "Toggle Terminal (from term)", noremap = true, silent = true })

-- File navigation
vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { desc = "Toggle Neo-tree", noremap = true, silent = true })
vim.keymap.set('n', '<C-p>', ':Telescope find_files<CR>', { desc = "Find Files", noremap = true, silent = true })
vim.keymap.set('n', '<C-g>', ':Telescope live_grep<CR>', { desc = "Live Grep", noremap = true, silent = true })

-- Save shortcuts
vim.keymap.set('n', '<C-s>', ':w<CR>', { desc = "Save File", noremap = true, silent = true })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { desc = "Save File (Insert)", noremap = true, silent = true })

-- Terminal escape
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = "Exit Terminal Mode", noremap = true, silent = true })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Window Left", noremap = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Window Down", noremap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Window Up", noremap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Window Right", noremap = true })

-- Test keymaps
vim.keymap.set('n', '<leader>tt', ':lua require("neotest").run.run()<CR>',
    { desc = "Run Nearest Test", noremap = true, silent = true })
vim.keymap.set('n', '<leader>tf', ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>',
    { desc = "Run Test File", noremap = true, silent = true })
vim.keymap.set('n', '<leader>ts', ':lua require("neotest").summary.toggle()<CR>',
    { desc = "Toggle Test Summary", noremap = true, silent = true })
vim.keymap.set('n', '<leader>to', ':lua require("neotest").output.open({ enter = true })<CR>',
    { desc = "Show Test Output", noremap = true, silent = true })

-- HTTP client keymaps (kulala for .http files)
vim.keymap.set('n', '<leader>rr', ':lua require("kulala").run()<CR>',
    { desc = "Run HTTP Request", noremap = true, silent = true })
vim.keymap.set('n', '<leader>ra', ':lua require("kulala").run_all()<CR>',
    { desc = "Run All HTTP Requests", noremap = true, silent = true })
vim.keymap.set('n', '<leader>ri', ':lua require("kulala").inspect()<CR>',
    { desc = "Inspect HTTP Request", noremap = true, silent = true })
vim.keymap.set('n', '<leader>rc', ':lua require("kulala").copy()<CR>',
    { desc = "Copy HTTP Request as cURL", noremap = true, silent = true })

-- Python-specific settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end
})

-- Prevent comment continuation globally
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})
