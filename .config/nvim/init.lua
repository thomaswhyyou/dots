-- Must define first before plugins are loaded
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--- OPTIONS ---

-- UI
vim.opt.number = true             -- Show line numbers (default: false)
vim.opt.relativenumber = true     -- Relative line numbers for easier motions (default: false)
vim.opt.signcolumn = "yes"        -- Always show sign column to avoid layout shift (default: "auto")
vim.opt.colorcolumn = "80"        -- Line length marker (default: "")
vim.opt.scrolloff = 8             -- Keep 8 lines visible above/below cursor (default: 0)
vim.opt.termguicolors = true      -- 24-bit RGB colors in the TUI (default: false)
vim.opt.showmode = false          -- Don't show mode in cmdline; statusline plugins handle it (default: true)
vim.opt.laststatus = 3            -- Enable global statusline at the bottom (default: 2)
vim.opt.cursorline = true         -- Highlight the current cursor line with CursorLine (default: false)
vim.opt.cursorlineopt = "number"  -- Highlight only the line number, not the entire line (default: "both")
vim.opt.cmdheight = 0             -- Hide command line when idle to remove the bottom gap (default: 1)
vim.opt.pumborder = "rounded"     -- The border style of popupmenu windows (default: "")
vim.opt.winborder = "rounded"     -- The border style of floating windows (default: "")
-- Indentation
vim.opt.expandtab = true          -- Use spaces instead of tabs (default: false)
vim.opt.smartindent = true        -- Auto-indent new lines based on syntax (default: false)
vim.opt.tabstop = 2               -- Spaces a <Tab> counts for (default: 8)
vim.opt.shiftwidth = 2            -- Spaces per indent level (default: 8)
vim.opt.softtabstop = -1          -- Makes <Tab> behave like shiftwidth (default: 0)
-- Search
vim.opt.ignorecase = true         -- Case-insensitive search (default: false)
vim.opt.smartcase = true          -- Case-sensitive if query has uppercase (default: false)
-- Text
vim.opt.list = true               -- Sets how to display certain whitespace characters in the editor.
vim.opt.listchars = {
  tab = "»·",
  trail = "·",
  nbsp = "␣",
}
vim.opt.linebreak = true          -- Wrap lines at word boundaries, not mid-word (default: false)
vim.opt.wrap = false              -- Don't wrap long lines visually (default: true)
-- Splits
vim.opt.splitbelow = true         -- Horizontal splits open below (default: false)
vim.opt.splitright = true         -- Vertical splits open to the right (default: false)
-- Undo / Swap
vim.opt.undofile = true           -- Persist undo history across sessions (default: false)
vim.opt.swapfile = false          -- Disable swap files; undo + git is enough (default: true)
-- Misc
vim.opt.clipboard = "unnamedplus" -- Use system clipboard for yank/paste (default: "")
vim.opt.updatetime = 250          -- Faster CursorHold events, useful for LSP/git gutters (default: 4000)
vim.opt.timeoutlen = 300          -- Faster key sequence completion (default: 1000)
vim.opt.confirm = true            -- Prompt to save instead of erroring on :q (default: false)

--- KEYMAPS ---

-- Clear search and other match highlights, and dismisses floating windows
-- currently on screen.
vim.keymap.set({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  vim.cmd("call clearmatches()")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })
-- Highlight word under cursor without moving (converted to Lua by ChatGTP)
-- http://vim.wikia.com/wiki/Highlight_all_search_pattern_matches#Highlight_matches_without_moving
vim.keymap.set("n", "<Leader><Space>", function()
  -- Put the <cword> into the search register with word boundaries
  vim.fn.setreg("/", "\\<" .. vim.fn.expand("<cword>") .. "\\>")
  -- Enable highlight search
  vim.opt.hlsearch = true
end, { desc = "Highlight all (*)", noremap = true, silent = true })
-- Select last inserted text.
vim.keymap.set("n", "gV", "`[v`]")
-- Better indenting, keep the selection in place and allows repeated indenting.
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
-- Scroll the current line up/down faster.
vim.keymap.set("n", "<C-e>", "8<C-e>")
vim.keymap.set("n", "<C-y>", "8<C-y>")
-- Paste and jump to the end of the pasted text, so you can paste multiple lines
-- multiple times with a simple ppppp.
vim.keymap.set("n", "p", "p`]", { noremap = true, silent = true })
-- In visual mode, replace the selection without clobbering the unnamed register
-- (delete into the black hole), then jump to the end of the pasted text.
vim.keymap.set("x", "p", '"_dP`]', { noremap = true, silent = true })
-- Toggle document colors (global scope, default off).
vim.keymap.set("n", "<leader>uc", function()
  vim.lsp.document_color.enable(not vim.lsp.document_color.is_enabled())
end, { desc = "Toggle document colors" })
vim.lsp.document_color.enable(false)
-- Jump straight to a tab by number with <A-N>.
for i = 1, 9 do
  vim.keymap.set("n", "<A-" .. i .. ">", i .. "gt", { desc = "Go to tab " .. i })
end

--- AUTOCMDS ---

-- Some copied from lazyvim (2026-05-11)
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
local function augroup(name)
  return vim.api.nvim_create_augroup("namespace_" .. name, { clear = true })
end
-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})
-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})
-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "mininotify-history",
    "checkhealth",
    "help",
    "qf",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})
-- Unlist man-page buffers so they don't show up in the buffer list and get
-- skipped by :bnext/:bprev. Keeps buffer navigation flowing only through real
-- files and makes the man buffer easy to close (:q) and forget.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})
-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
-- Turn on cursorline and relativenumber in the currently focused buffer only.
-- Restrict to real file buffers (buftype == ""), which excludes special windows
-- like NvimTree, help, quickfix, and terminals.
local active_buffer_group = augroup("active_buffer")
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter" }, {
  group = active_buffer_group,
  callback = function()
    if vim.bo.buftype ~= "" then return end
    vim.opt_local.cursorline = true
    vim.opt_local.relativenumber = true
  end,
})
vim.api.nvim_create_autocmd("WinLeave", {
  group = active_buffer_group,
  callback = function()
    if vim.bo.buftype ~= "" then return end
    vim.opt_local.cursorline = false
    vim.opt_local.relativenumber = false
  end,
})

--- PACKAGES ---

-- https://lazy.folke.io/installation
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out =
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "monokai-pro" } },
  checker = { enabled = true },
  rocks = { enabled = false },
})

--- References ---
-- https://neovim.io/doc/user/options/
-- https://github.com/ibhagwan/vim-cheatsheet
-- https://github.com/mhinz/vim-galore

--- Examples ---
-- https://github.com/CosmicNvim/CosmicNvim
-- https://github.com/NormalNvim/NormalNvim
-- https://github.com/AstroNvim/AstroNvim
-- https://github.com/LunarVim/LunarVim

--- Todos ---
-- tab / s+tab for navigation
-- sql/http interface
-- vim.o.autocomplete
-- https://github.com/cursortab/cursortab.nvim
-- https://github.com/zuqini/zpack.nvim
-- https://github.com/jtprogru/pack-ui.nvim
-- https://github.com/kite12580/pack.lua/tree/main
-- https://fredrikaverpil.github.io/blog/2026/04/15/from-lazy.nvim-to-vim.pack/
