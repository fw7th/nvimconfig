-- Bootstrap lazy.nvim plugin manager
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

-- Set leader key before lazy setup
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core Neovim Settings
vim.opt.shortmess:append("I")  -- Remove intro
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cursorline = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hidden = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.mouse = "a"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.signcolumn = "yes"
vim.opt.undofile = true
vim.opt.swapfile = false

-- Disable built-in completion to avoid unwanted popups
vim.opt.completeopt = ""

-- FIXED: Disable auto-comment continuation globally - this is the main fix
vim.opt.formatoptions:remove({ "c", "r", "o" })

-- Disable diagnostic virtual text (those annoying inline error messages)
vim.diagnostic.config({
    virtual_text = false,  -- This removes the inline error messages
    signs = true,          -- Keep the signs in the sign column
    underline = true,      -- Keep underlines for errors
    update_in_insert = false,  -- Don't update diagnostics while typing
})

-- Custom Color Palette
local colors = {
    -- Background - glossy black (mix of gray and black, easy on eyes)
    background = {
        main = "#1a1a1a",     -- Glossy black - not too deep, easy on eyes
        darker = "#0f0f0f",   -- Slightly darker variant
        lighter = "#2a2a2a"   -- Slightly lighter variant
    },

    -- Main colors
    white = "#ffffff",        -- Pure white
    light_blue = "#87ceeb",   -- Light blue (sky blue)
    accent = "#ff6b47",       -- Subdued red-orange (warm but not too bright)
    
    -- Additional utility colors
    muted_white = "#e0e0e0",  -- Slightly muted white for less important text
    pale_blue = "#b8d4f0",    -- Even paler blue for subtle elements
}

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
                terminal_colors = true,
                styles = {
                    comments = { italic = true },
                    keywords = { italic = true },
                },
                on_colors = function(theme_colors)
                    -- Replace ALL colors with our custom palette
                    theme_colors.bg = colors.background.main
                    theme_colors.bg_dark = colors.background.darker
                    theme_colors.bg_sidebar = colors.background.main
                    theme_colors.bg_float = colors.background.main

                    -- Text colors
                    theme_colors.fg = colors.white
                    theme_colors.fg_dark = colors.muted_white
                    theme_colors.fg_float = colors.white

                    -- Accent colors - map to our three main colors
                    theme_colors.blue = colors.light_blue
                    theme_colors.green = colors.accent
                    theme_colors.red = colors.accent
                    theme_colors.yellow = colors.accent
                    theme_colors.cyan = colors.light_blue
                    theme_colors.magenta = colors.accent
                end,
                on_highlights = function(highlights, theme_colors)
                    local groups = {
                        'Normal', 'NormalNC', 'SignColumn', 'EndOfBuffer',
                        'LineNr', 'CursorLineNr', 'CursorLine',
                        'DiagnosticError', 'DiagnosticWarn',
                        'DiagnosticInfo', 'DiagnosticHint',
                        'Comment', 'Identifier', 'Keyword',
                        'Function', 'String', 'Operator'
                    }

                    for _, group in ipairs(groups) do
                        highlights[group] = {
                            bg = (group == 'CursorLine' and colors.background.lighter) or colors.background.main,
                            fg = (group == 'LineNr' and colors.pale_blue) or
                                (group == 'CursorLineNr' and colors.light_blue) or
                                (group == 'Comment' and colors.muted_white) or
                                (group == 'String' and colors.white) or
                                (group == 'Identifier' and colors.white) or
                                (group == 'Keyword' and colors.accent) or
                                (group == 'Function' and colors.light_blue) or
                                (group == 'Operator' and colors.muted_white) or
                                colors.white,
                            italic = group == 'Comment' or group == 'Keyword'
                        }
                    end
                end,
            })
            vim.cmd [[colorscheme tokyonight-night]]
        end
    },

    -- Flutter Tools - Essential for Flutter development
    {
        "akinsho/flutter-tools.nvim",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim", -- optional for vim.ui.select
        },
        config = function()
            require("flutter-tools").setup {
                ui = {
                    border = "rounded",
                },
                decorations = {
                    statusline = {
                        app_version = false,
                        device = true,
                    }
                },
                debugger = {
                    enabled = true,
                    run_via_dap = false,
                },
                flutter_path = nil, -- Uses system flutter
                flutter_lookup_cmd = nil,
                fvm = false, -- Set to true if using FVM
                widget_guides = {
                    enabled = true,
                },
                closing_tags = {
                    highlight = "Comment",
                    prefix = "// ",
                    enabled = true
                },
                dev_log = {
                    enabled = true,
                    notify_errors = false,
                },
                lsp = {
                    color = {
                        enabled = true,
                        background = false,
                        background_color = nil,
                        foreground = false,
                        virtual_text = true,
                        virtual_text_str = "■",
                    },
                    on_attach = function(client, bufnr)
                        -- Flutter-specific LSP keymaps
                        local opts = { noremap = true, silent = true, buffer = bufnr }
                        
                        -- Standard LSP keymaps
                        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
                        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
                        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
                        
                        -- Flutter-specific keymaps
                        vim.keymap.set('n', '<leader>fr', ':FlutterRestart<CR>', opts)
                        vim.keymap.set('n', '<leader>fR', ':FlutterReload<CR>', opts)
                        vim.keymap.set('n', '<leader>fq', ':FlutterQuit<CR>', opts)
                        vim.keymap.set('n', '<leader>fd', ':FlutterDevices<CR>', opts)
                        vim.keymap.set('n', '<leader>fe', ':FlutterEmulators<CR>', opts)
                        vim.keymap.set('n', '<leader>fo', ':FlutterOutlineToggle<CR>', opts)
                        vim.keymap.set('n', '<leader>ft', ':FlutterDevTools<CR>', opts)
                        vim.keymap.set('n', '<leader>fc', ':FlutterCopyProfilerUrl<CR>', opts)
                    end,
                    capabilities = function(config)
                        config.textDocument.completion.completionItem.snippetSupport = true
                        return config
                    end,
                    -- Dart LSP settings
                    settings = {
                        showTodos = true,
                        completeFunctionCalls = true,
                        analysisExcludedFolders = {
                            vim.fn.expand("$HOME/.pub-cache"),
                            vim.fn.expand("$HOME/fvm"),
                        },
                        updateImportsOnRename = true,
                        suggestFromUnimportedLibraries = true,
                        closingLabels = true,
                    }
                }
            }
        end
    },

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup({
                ui = {
                    border = "rounded",
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })
            
            -- Wrap mason-lspconfig in pcall to suppress errors
            local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
            if mason_lspconfig_ok then
                pcall(function()
                    mason_lspconfig.setup({
                        ensure_installed = { "pyright", "clangd", "dartls" },
                        automatic_installation = true,
                    })
                end)
            end
                        
            local lspconfig = require("lspconfig")
            
            -- Shared on_attach function for non-Flutter LSPs
            local on_attach = function(client, bufnr)
                -- Configure formatting capabilities
                if client.name == "clangd" then
                    client.server_capabilities.documentFormattingProvider = true
                    client.server_capabilities.documentRangeFormattingProvider = true
                else
                    client.server_capabilities.documentFormattingProvider = false
                    client.server_capabilities.documentRangeFormattingProvider = false
                end
                
                local opts = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
                
                -- Only add formatting keymap if the server supports it
                if client.server_capabilities.documentFormattingProvider then
                    vim.keymap.set('n', '<leader>f', function()
                        vim.lsp.buf.format({ async = true })
                    end, opts)
                end
            end
            
            -- Python LSP
            lspconfig.pyright.setup({
                on_attach = on_attach,
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                        },
                    },
                },
            })
            
            -- C++ LSP
            lspconfig.clangd.setup({
                on_attach = on_attach,
                cmd = {
                    "clangd",
                    "--background-index",
                    "--header-insertion=iwyu",
                    "--fallback-style=Google",
                    "--clang-tidy",
                },
                filetypes = {"c", "cpp", "objc", "objcpp"},
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                },
            })

            -- Dart LSP (only for pure Dart files, Flutter is handled by flutter-tools)
            lspconfig.dartls.setup({
                on_attach = on_attach,
                cmd = { "dart", "language-server", "--protocol=lsp" },
                filetypes = { "dart" },
                init_options = {
                    onlyAnalyzeProjectsWithOpenFiles = true,
                    suggestFromUnimportedLibraries = true,
                    closingLabels = true,
                    outline = true,
                    flutterOutline = false, -- This is handled by flutter-tools
                },
                settings = {
                    dart = {
                        completeFunctionCalls = true,
                        showTodos = true,
                    }
                }
            })
        end
    },

    -- Treesitter for better syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "python", "cpp", "lua", "dart",
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    enable = true,
                },
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
                enable_diagnostics = true,
                enable_git_status = true,
                filesystem = {
                    follow_current_file = {
                        enabled = true,
                        leave_dirs_open = false,
                    },
                    hijack_netrw_behavior = "open_current",
                    use_libuv_file_watcher = true,
                    filtered_items = {
                        visible = false,
                        hide_dotfiles = true,
                        hide_gitignored = true,
                        hide_hidden = true,
                        hide_by_name = {
                            ".git",
                            ".DS_Store",
                            "thumbs.db",
                            "node_modules",
                            ".dart_tool",
                            "build",
                        },
                    },
                },
                window = {
                    width = 30,
                    mappings = {
                        ["<space>"] = "none",
                    },
                },
            })
            vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { noremap = true, silent = true })
        end
    },

    -- Telescope (minimal setup)
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("telescope").setup({
                defaults = {
                    file_ignore_patterns = { 
                        "node_modules", ".git/", "env/", "venv/",
                        "__pycache__", "*.pyc", ".pytest_cache", "*.log",
                        ".dart_tool/", "build/", "*.lock", ".pub-cache/"
                    },
                    path_display = { "smart" },
                },
            })

            local builtin = require("telescope.builtin")
            vim.keymap.set('n', '<C-p>', builtin.find_files, {})
            vim.keymap.set('n', '<C-g>', builtin.live_grep, {})
        end
    },

    -- Formatting - enhanced with Dart support
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    python = { "black" },
                    cpp = { "clang-format" },
                    dart = { "dart_format" },
                },
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
                format_after_save = false,
                formatters = {
                    clang_format = {
                        prepend_args = { "--style=Google" }
                    },
                    dart_format = {
                        command = "dart",
                        args = { "format", "--stdin-name", "$FILENAME" },
                        stdin = true,
                    }
                }
            })
            
            -- Add keymapping for manual formatting
            vim.keymap.set('n', '<leader>fm', function()
                require("conform").format({ async = true })
            end, { noremap = true, silent = true, desc = 'Format with conform.nvim' })
        end
    },

    -- Add indent guides to better visualize indentation
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            require("ibl").setup {
                indent = { char = "│" },
                scope = { enabled = true },
            }
        end
    },

    -- Optional: Dart/Flutter snippets
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        config = function()
            local ls = require("luasnip")
            local s = ls.snippet
            local t = ls.text_node
            local i = ls.insert_node

            -- Basic Dart/Flutter snippets
            ls.add_snippets("dart", {
                s("stless", {
                    t({"class "}), i(1, "ClassName"), t({" extends StatelessWidget {", 
                        "  const "}), i(2), t({"({Key? key}) : super(key: key);", 
                        "", 
                        "  @override", 
                        "  Widget build(BuildContext context) {", 
                        "    return "}), i(3, "Container()"), t({";", 
                        "  }", 
                        "}"})
                }),
                s("stful", {
                    t({"class "}), i(1, "ClassName"), t({" extends StatefulWidget {", 
                        "  const "}), i(2), t({"({Key? key}) : super(key: key);", 
                        "", 
                        "  @override", 
                        "  State<"}), i(3), t({"> createState() => _"}), i(4), t({"State();", 
                        "}", 
                        "", 
                        "class _"}), i(5), t({"State extends State<"}), i(6), t({"> {", 
                        "  @override", 
                        "  Widget build(BuildContext context) {", 
                        "    return "}), i(7, "Container()"), t({";", 
                        "  }", 
                        "}"})
                }),
            })
        end
    },
}, {
    -- Lazy.nvim configuration
    ui = {
        border = "rounded",
        icons = {
            loaded = "✓",
            not_loaded = "✗"
        }
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin"
            }
        }
    }
})

-- Terminal settings and functions
vim.opt.shell = '/bin/bash'
vim.opt.shellcmdflag = '-c'
vim.opt.shellquote = ""
vim.opt.shellxquote = ""

-- Terminal state variables
local term_buf = nil
local term_win = nil

-- Enhanced Run Code Function with Dart/Flutter support
function RunCode()
    local ft = vim.bo.filetype
    local file = vim.fn.expand('%:p')
    local out = vim.fn.expand('%:p:r')
    
    -- Save current buffer
    vim.cmd('write')
    
    -- Close existing terminal window if it exists
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
    end
    
    -- Create new terminal window
    vim.cmd('botright 15new')
    vim.cmd('term')
    
    term_win = vim.api.nvim_get_current_win()
    term_buf = vim.api.nvim_get_current_buf()
    
    -- Configure terminal window
    vim.wo.number = false
    vim.wo.relativenumber = false
    
    -- Execute based on filetype
    if ft == 'cpp' then
        vim.api.nvim_chan_send(vim.b.terminal_job_id,
            string.format('clear && g++ -std=c++17 -Wall -Wextra "%s" -o "%s" && "%s" || echo "Compilation failed"\n',
                file, out, out))
    elseif ft == 'python' then
        vim.api.nvim_chan_send(vim.b.terminal_job_id,
            string.format('clear && python3 -u "%s" || echo "Execution failed"\n',
                file))
    elseif ft == 'dart' then
        -- Check if it's a Flutter project
        if vim.fn.filereadable('pubspec.yaml') == 1 then
            local pubspec_content = vim.fn.readfile('pubspec.yaml')
            local is_flutter = false
            for _, line in ipairs(pubspec_content) do
                if string.match(line, "flutter:") then
                    is_flutter = true
                    break
                end
            end
            
            if is_flutter then
                vim.api.nvim_chan_send(vim.b.terminal_job_id,
                    'clear && echo "Use :FlutterRun for Flutter apps or run: flutter run" || echo "Flutter run failed"\n')
            else
                vim.api.nvim_chan_send(vim.b.terminal_job_id,
                    string.format('clear && dart "%s" || echo "Dart execution failed"\n', file))
            end
        else
            vim.api.nvim_chan_send(vim.b.terminal_job_id,
                string.format('clear && dart "%s" || echo "Dart execution failed"\n', file))
        end
    else
        print("Unsupported file type for running!")
        vim.api.nvim_win_close(term_win, true)
        return
    end
    
    -- Determine if interactive input is expected
    local is_interactive = false
    if ft == 'cpp' then
        is_interactive = vim.fn.system('grep -c "std::cin" "' .. file .. '"') ~= '0\n'
    elseif ft == 'python' then
        is_interactive = vim.fn.system('grep -c "input(" "' .. file .. '"') ~= '0\n'
    elseif ft == 'dart' then
        is_interactive = vim.fn.system('grep -c "stdin.readLine" "' .. file .. '"') ~= '0\n'
    end
    
    if is_interactive then
        vim.cmd('startinsert')
    else
        vim.cmd('wincmd p')
    end
end

-- Enhanced Terminal Toggle Function
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

-- Terminal and code running keymaps
vim.keymap.set('n', '<F5>', RunCode, { noremap = true, silent = true, desc = 'Run Code' })
vim.keymap.set('n', '<F4>', ToggleTerminal, { noremap = true, silent = true, desc = 'Toggle Terminal' })
vim.keymap.set('t', '<F4>', '<C-\\><C-n>:lua ToggleTerminal()<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })

-- Flutter-specific global keymaps
vim.keymap.set('n', '<leader>Fs', ':FlutterRun<CR>', { noremap = true, silent = true, desc = 'Flutter Run' })
vim.keymap.set('n', '<leader>Fh', ':FlutterRestart<CR>', { noremap = true, silent = true, desc = 'Flutter Hot Restart' })
vim.keymap.set('n', '<leader>Fr', ':FlutterReload<CR>', { noremap = true, silent = true, desc = 'Flutter Hot Reload' })
vim.keymap.set('n', '<leader>Fq', ':FlutterQuit<CR>', { noremap = true, silent = true, desc = 'Flutter Quit' })
vim.keymap.set('n', '<leader>Fd', ':FlutterDevices<CR>', { noremap = true, silent = true, desc = 'Flutter Devices' })

-- Essential keymaps
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true, silent = true, desc = 'Save file' })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { noremap = true, silent = true, desc = 'Save file' })
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, desc = 'Move to top window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, desc = 'Move to right window' })

-- Enhanced Copy and Paste Keymaps
vim.keymap.set('n', '<leader>y', '"+y', { noremap = true, desc = 'Copy to system clipboard' })
vim.keymap.set('v', '<leader>y', '"+y', { noremap = true, desc = 'Copy to system clipboard' })
vim.keymap.set('n', '<leader>p', '"+p', { noremap = true, desc = 'Paste from system clipboard' })
vim.keymap.set('v', '<leader>p', '"+p', { noremap = true, desc = 'Paste from system clipboard' })

-- Search and Find Keymaps
vim.keymap.set('n', '<leader>/', ':nohlsearch<CR>', { noremap = true, silent = true, desc = 'Clear search highlights' })
vim.keymap.set('n', 'n', 'nzzzv', { noremap = true, desc = 'Center screen on next search result' })
vim.keymap.set('n', 'N', 'Nzzzv', { noremap = true, desc = 'Center screen on previous search result' })

-- Quick window management
vim.keymap.set('n', 'Q', ':q<CR>', { noremap = true, silent = true, desc = 'Quit current window' })
vim.keymap.set('n', '<leader>q', ':qa<CR>', { noremap = true, silent = true, desc = 'Quit all windows' })

-- MAIN FIX: Comprehensive autocmd group to handle formatoptions consistently
local format_group = vim.api.nvim_create_augroup("FormatOptions", { clear = true })

-- Apply formatoptions fix more aggressively and consistently
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufRead", "BufNewFile" }, {
    group = format_group,
    pattern = "*",
    callback = function()
        -- Remove comment continuation options
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
        -- Also remove 't' to prevent auto-wrapping of text
        vim.opt_local.formatoptions:remove("t")
    end,
})

-- Extra protection: Apply after any filetype detection
vim.api.nvim_create_autocmd("FileType", {
    group = format_group,
    pattern = "*",
    callback = function()
        -- Wait a bit to ensure this runs after other plugins
        vim.defer_fn(function()
            vim.opt_local.formatoptions:remove({ "c", "r", "o", "t" })
        end, 50)
    end,
})

-- Add C++ specific auto-formatting settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = "cpp",
    callback = function()
        -- Apply formatoptions fix for C++ files
        vim.opt_local.formatoptions:remove({ "c", "r", "o", "t" })
        
        -- Add formatprg for C++
        vim.opt_local.formatprg = "clang-format --style=Google"
        
        -- Disable completion popup in C++ files
        vim.opt_local.completeopt = ""
        
        -- Add keybinding for manual formatting in C++ files
        vim.keymap.set('n', '<leader>cf', function()
            vim.cmd("silent !clang-format -i -style=Google " .. vim.fn.expand("%"))
            vim.cmd("e") -- Reload the file
        end, { buffer = true, desc = "Format C++ file with clang-format" })
        
        -- Add a quick format shortcut that's easier to remember
        vim.keymap.set('n', '<F3>', function()
            vim.lsp.buf.format({ async = true })
        end, { buffer = true, desc = "Format C++ file" })
    end
})

-- Python specific settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o", "t" })
    end
})

-- Dart specific settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = "dart",
    callback = function()
        -- Apply formatoptions fix for Dart files
        vim.opt_local.formatoptions:remove({ "c", "r", "o", "t" })
        
        -- Set Dart-specific indentation (2 spaces is standard for Dart/Flutter)
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
        
        -- Add formatprg for Dart
        vim.opt_local.formatprg = "dart format"
        
        -- Disable completion popup in Dart files
        vim.opt_local.completeopt = ""
        
        -- Add keybinding for manual formatting in Dart files
        vim.keymap.set('n', '<leader>df', function()
            vim.cmd("silent !dart format " .. vim.fn.expand("%"))
            vim.cmd("e") -- Reload the file
        end, { buffer = true, desc = "Format Dart file" })
        
        -- Add a quick format shortcut for Dart
        vim.keymap.set('n', '<F3>', function()
            vim.lsp.buf.format({ async = true })
        end, { buffer = true, desc = "Format Dart file" })
        
        -- Flutter-specific keymaps when in a Flutter project
        if vim.fn.filereadable('pubspec.yaml') == 1 then
            local pubspec_content = vim.fn.readfile('pubspec.yaml')
            for _, line in ipairs(pubspec_content) do
                if string.match(line, "flutter:") then
                    -- Additional Flutter-specific keymaps for this buffer
                    vim.keymap.set('n', '<leader>fw', ':FlutterOutlineToggle<CR>', 
                        { buffer = true, desc = "Toggle Flutter Widget Outline" })
                    vim.keymap.set('n', '<leader>fp', ':FlutterPubGet<CR>', 
                        { buffer = true, desc = "Flutter Pub Get" })
                    break
                end
            end
        end
    end
})

-- Create a .clang-format file if it doesn't exist in the current directory
vim.api.nvim_create_user_command("CreateClangFormat", function()
    local file = ".clang-format"
    if vim.fn.filereadable(file) == 0 then
        local f = io.open(file, "w")
        if f then
            f:write("---\n")
            f:write("Language: Cpp\n")
            f:write("BasedOnStyle: Google\n")
            f:write("IndentWidth: 4\n")
            f:write("TabWidth: 4\n")
            f:write("UseTab: Never\n")
            f:write("ColumnLimit: 100\n")
            f:write("AlignConsecutiveAssignments: true\n")
            f:write("AlignConsecutiveDeclarations: true\n")
            f:write("AllowShortFunctionsOnASingleLine: Empty\n")
            f:write("AllowShortIfStatementsOnASingleLine: false\n")
            f:write("AllowShortLoopsOnASingleLine: false\n")
            f:write("BreakBeforeBraces: Linux\n")
            f:write("IndentCaseLabels: true\n")
            f:write("SpaceBeforeParens: ControlStatements\n")
            f:write("AccessModifierOffset: -4\n")
            f:close()
            print("Created .clang-format with Google style")
        else
            print("Failed to create .clang-format file")
        end
    else
        print(".clang-format already exists")
    end
end, {})

-- Create analysis_options.yaml for Dart projects
vim.api.nvim_create_user_command("CreateDartAnalysis", function()
    local file = "analysis_options.yaml"
    if vim.fn.filereadable(file) == 0 then
        local f = io.open(file, "w")
        if f then
            f:write("include: package:flutter_lints/flutter.yaml\n")
            f:write("\n")
            f:write("analyzer:\n")
            f:write("  exclude:\n")
            f:write("    - \"**/*.g.dart\"\n")
            f:write("    - \"**/*.freezed.dart\"\n")
            f:write("\n")
            f:write("linter:\n")
            f:write("  rules:\n")
            f:write("    prefer_single_quotes: true\n")
            f:write("    use_key_in_widget_constructors: false\n")
            f:write("    file_names: false\n")
            f:close()
            print("Created analysis_options.yaml for Dart/Flutter")
        else
            print("Failed to create analysis_options.yaml file")
        end
    else
        print("analysis_options.yaml already exists")
    end
end, {})

-- Flutter project initialization helper
vim.api.nvim_create_user_command("FlutterInit", function()
    local current_dir = vim.fn.getcwd()
    local project_name = vim.fn.input("Enter Flutter project name: ")
    if project_name ~= "" then
        vim.cmd("!" .. "flutter create " .. project_name)
        print("Flutter project '" .. project_name .. "' created!")
    end
end, {})

-- Add command to format current file
vim.api.nvim_create_user_command("Format", function()
    vim.lsp.buf.format({ async = true })
end, {})

-- Debug command to check current formatoptions
vim.api.nvim_create_user_command("CheckFormatOptions", function()
    print("Current formatoptions: " .. vim.opt_local.formatoptions:get())
end, {})
