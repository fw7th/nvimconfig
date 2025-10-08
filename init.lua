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
vim.opt.completeopt = ""
vim.opt.formatoptions:remove({ "c", "r", "o" })

-- Disable the Neovim intro message/screen (the "children in Uganda thing")
vim.opt.shortmess:append("I")

-- Disable inline diagnostics
vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = false,
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

    -- Flutter Tools
    {
        "akinsho/flutter-tools.nvim",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("flutter-tools").setup {
                widget_guides = { enabled = true },
                closing_tags = {
                    highlight = "Comment",
                    prefix = "// ",
                    enabled = true
                },
                lsp = {
                    -- Use the same on_attach logic as your main LSP setup
                    on_attach = function(client, bufnr)
                        local opts = { noremap = true, silent = true, buffer = bufnr }
                        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
                        vim.keymap.set('n', '<leader>f', function()
                            vim.lsp.buf.format({ async = true })
                        end, opts)
                    end,
                    settings = {
                        showTodos = true,
                        completeFunctionCalls = true,
                        updateImportsOnRename = true,
                        suggestFromUnimportedLibraries = true,
                    }
                }
            }
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
                -- ADDED 'rust_analyzer'
                ensure_installed = { "pyright", "clangd", "rust_analyzer" },
                automatic_installation = true,
            })

            local lspconfig = require("lspconfig")

            -- Common on_attach function for keymaps
            local on_attach = function(client, bufnr)
                local opts = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', '<leader>f', function()
                    vim.lsp.buf.format({ async = true })
                end, opts)
            end

            -- Python
            lspconfig.pyright.setup({ on_attach = on_attach })

            -- C/C++
            lspconfig.clangd.setup({
                on_attach = on_attach,
                cmd = { "clangd", "--background-index", "--clang-tidy" },
            })

            -- RUST: ADDED rust_analyzer setup
            lspconfig.rust_analyzer.setup({
                on_attach = on_attach,
                settings = {
                    ["rust-analyzer"] = {
                        checkOnSave = {
                            command = "clippy",
                        },
                    },
                },
            })

            -- Dart (for non-Flutter Dart projects)
            if vim.fn.executable('dart') == 1 then
                lspconfig.dartls.setup({
                    on_attach = on_attach,
                    cmd = { "dart", "language-server", "--protocol=lsp" },
                    filetypes = { "dart" },
                    init_options = {
                        onlyAnalyzeProjectsWithOpenFiles = true,
                        suggestFromUnimportedLibraries = true,
                        closingLabels = true,
                    },
                    settings = {
                        dart = {
                            completeFunctionCalls = true,
                            showTodos = true,
                        }
                    }
                })
            end
        end
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                -- ADDED 'rust'
                ensure_installed = { "python", "cpp", "c", "lua", "dart", "rust" },
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
                            ".dart_tool",
                            "build",
                            "__pycache__",
                            -- ADDED Rust build directories
                            "target",
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
                        ".dart_tool/", "build/",
                        -- ADDED Rust build directories
                        "target/"
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
                    python = { "black" },
                    cpp = { "clang-format" },
                    c = { "clang-format" },
                    dart = { "dart_format" },
                    -- ADDED Rust formatter
                    rust = { "rustfmt" },
                },
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
                formatters = {
                    dart_format = {
                        command = "dart",
                        args = { "format", "--stdin-name", "$FILENAME" },
                        stdin = true,
                    }
                }
            })
        end
    },
})

-- Terminal state variables
local term_buf = nil
local term_win = nil

-- Run Code Function
function RunCode()
    local ft = vim.bo.filetype
    local file = vim.fn.expand('%:p')
    local out = vim.fn.expand('%:p:r')

    vim.cmd('write')

    -- Close existing terminal if open
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
    end

    -- Create new terminal
    vim.cmd('botright 15new')
    vim.cmd('term')

    term_win = vim.api.nvim_get_current_win()
    term_buf = vim.api.nvim_get_current_buf()

    vim.wo.number = false
    vim.wo.relativenumber = false

    if ft == 'cpp' or ft == 'c' then
        -- Compile and run C/C++
        local compiler = ft == 'cpp' and 'g++ -std=c++17' or 'gcc'
        vim.api.nvim_chan_send(vim.b.terminal_job_id,
            string.format('clear && %s -Wall "%s" -o "%s" && "%s"\n',
                compiler, file, out, out))
    elseif ft == 'python' then
        -- Run Python
        vim.api.nvim_chan_send(vim.b.terminal_job_id,
            string.format('clear && python3 "%s"\n', file))
    elseif ft == 'dart' then
        -- Run Dart
        vim.api.nvim_chan_send(vim.b.terminal_job_id,
            string.format('clear && dart "%s"\n', file))
    elseif ft == 'rust' then
        -- Run Rust (Compile and Run)
        -- Note: rustc is used for single file execution. For projects, 'cargo run' is preferred.
        -- We will use rustc here for consistency with other single-file runners.
        vim.api.nvim_chan_send(vim.b.terminal_job_id,
            string.format('clear && rustc "%s" -o "%s" && "%s"\n', file, out, out))
    else
        print("Unsupported file type for RunCode!")
        vim.cmd('close')
    end
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
vim.keymap.set('n', '<F5>', RunCode, { desc = "Run Code (Compile/Execute)", noremap = true, silent = true })
vim.keymap.set('n', '<F4>', ToggleTerminal, { desc = "Toggle Terminal", noremap = true, silent = true })
vim.keymap.set('t', '<F4>', '<C-\\><C-n>:lua ToggleTerminal()<CR>',
    { desc = "Toggle Terminal (from term)", noremap = true, silent = true })
vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { desc = "Toggle Neo-tree", noremap = true, silent = true })
vim.keymap.set('n', '<C-p>', ':Telescope find_files<CR>', { desc = "Find Files", noremap = true, silent = true })
vim.keymap.set('n', '<C-g>', ':Telescope live_grep<CR>',
    { desc = "Live Grep (Search Content)", noremap = true, silent = true })
vim.keymap.set('n', '<C-s>', ':w<CR>', { desc = "Save File (Normal Mode)", noremap = true, silent = true })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { desc = "Save File (Insert Mode)", noremap = true, silent = true })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = "Exit Terminal Insert Mode", noremap = true, silent = true })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Window Left", noremap = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Window Down", noremap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Window Up", noremap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Window Right", noremap = true })

-- Flutter commands
vim.keymap.set('n', '<leader>fs', ':FlutterRun<CR>', { desc = "Flutter Run/Start", noremap = true, silent = true })
vim.keymap.set('n', '<leader>fr', ':FlutterRestart<CR>', { desc = "Flutter Hot Restart", noremap = true, silent = true })
vim.keymap.set('n', '<leader>fq', ':FlutterQuit<CR>', { desc = "Flutter Quit App", noremap = true, silent = true })

-- Language-specific indentation settings (kept your preferences)
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function()
        -- Keeping your C/C++ 2-space preference
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "dart",
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end
})

vim.api.nvim_create_autocmd("FileType", {
    -- ADDED "rust"
    pattern = { "python", "lua", "rust" },
    callback = function()
        -- Setting 4-space for Python, Lua, and Rust
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
