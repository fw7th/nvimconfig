-- ~/.config/nvim/lua/config/terminal.lua
-- Scratch terminal + language runners (F4-F7).
--
-- These were previously global functions (function RunPython() ... end sitting
-- in _G). Wrapping them in a local module table `M` keeps them out of the
-- global namespace -- nothing else in your config *needs* to call RunPython()
-- from outside this file, so there's no reason for it to be reachable as
-- _G.RunPython. Keymaps below call M.run_python() directly instead.

local M = {}

-- Shared terminal state
local term_win = nil
local term_buf = nil

-- Close the scratch terminal window if it's open. Shared by every runner
-- so we don't stack multiple terminal splits.
local function close_existing_terminal()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
    end
end

-- Open a fresh 5-line terminal split at the bottom and return its job id.
local function open_terminal()
    vim.cmd("botright 5new")
    vim.cmd("term")
    term_win = vim.api.nvim_get_current_win()
    term_buf = vim.api.nvim_get_current_buf()
    vim.wo.number = false
    vim.wo.relativenumber = false
    return vim.b.terminal_job_id
end

--- Run the current file as a uvicorn/FastAPI dev server.
function M.run_fastapi()
    vim.cmd("write")

    local current_file = vim.fn.expand("%:p")
    local project_root = vim.fn.fnamemodify(current_file, ":h:h")
    if project_root == nil or project_root == "" then
        vim.notify("Invalid buffer path; cannot set working directory.", vim.log.levels.WARN)
        return
    end
    vim.cmd("lcd " .. project_root)

    close_existing_terminal()

    if vim.fn.filereadable(current_file) == 0 then
        vim.notify("Current file is not readable on disk", vim.log.levels.ERROR)
        return
    end

    local job_id = open_terminal()
    if not job_id then
        vim.notify("No terminal job found", vim.log.levels.ERROR)
        return
    end

    -- Derive dotted module path from the relative file path, e.g.
    -- app/main.py -> app.main
    local rel_path = vim.fn.fnamemodify(current_file, ":.:r")
    local module_name = rel_path:gsub("/", ".")

    vim.api.nvim_chan_send(job_id,
        string.format("clear && uvicorn %s:app --reload --log-level debug --host 127.0.0.1 --port 8000\n",
            module_name))

    vim.notify("Module path: " .. module_name)
end

--- Run the current file as a Python module (python3 -m ...).
function M.run_python()
    vim.cmd("write")

    local file = vim.fn.expand("%:p")
    local cwd = vim.fn.getcwd()

    local module = file
        :gsub(cwd .. "/", "")
        :gsub("%.py$", "")
        :gsub("/", ".")

    close_existing_terminal()
    local job_id = open_terminal()

    vim.api.nvim_chan_send(job_id, string.format("clear && python3 -m %s\n", module))
end

--- Run pytest in the current working directory.
function M.run_pytest()
    vim.cmd("write")
    close_existing_terminal()
    local job_id = open_terminal()
    vim.api.nvim_chan_send(job_id, "clear && pytest -v\n")
end

--- Toggle the scratch terminal open/closed (no command run).
function M.toggle()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
        term_win = nil
        term_buf = nil
    else
        open_terminal()
        vim.cmd("startinsert")
    end
end

-- Keymaps (colocated with the functions they call)
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<F5>", M.run_python, vim.tbl_extend("force", opts, { desc = "Run Python Script" }))
vim.keymap.set("n", "<F6>", M.run_fastapi, vim.tbl_extend("force", opts, { desc = "Run FastAPI Server" }))
vim.keymap.set("n", "<F7>", M.run_pytest, vim.tbl_extend("force", opts, { desc = "Run Pytest" }))
vim.keymap.set("n", "<F4>", M.toggle, vim.tbl_extend("force", opts, { desc = "Toggle Terminal" }))
vim.keymap.set("t", "<F4>", "<C-\\><C-n>:lua require('config.terminal').toggle()<CR>",
    vim.tbl_extend("force", opts, { desc = "Toggle Terminal (from term)" }))

return M
