-- Note: Also supports navigation between Neovim and herdr panes.
return {
  "https://github.com/lmilojevicc/herdr-splits.nvim",
  cond = vim.env.HERDR_ENV == "1",
  build = 'lua require("herdr-splits").sync_herdr()',
  config = function()
    local hs = require("herdr-splits")
    hs.setup({ auto_sync_herdr = true })

    -- moving between splits / herdr panes
    local function maybe_move(move)
      return function()
        if vim.w.is_overlook_popup then return end
        if vim.w.snacks_main then return end
        move()
      end
    end
    vim.keymap.set({ "n", "t" }, "<C-h>", maybe_move(hs.move_cursor_left))
    vim.keymap.set({ "n", "t" }, "<C-j>", maybe_move(hs.move_cursor_down))
    vim.keymap.set({ "n", "t" }, "<C-k>", maybe_move(hs.move_cursor_up))
    vim.keymap.set({ "n", "t" }, "<C-l>", maybe_move(hs.move_cursor_right))
    -- resizing splits
    vim.keymap.set("n", "<M-h>", hs.resize_left)
    vim.keymap.set("n", "<M-j>", hs.resize_down)
    vim.keymap.set("n", "<M-k>", hs.resize_up)
    vim.keymap.set("n", "<M-l>", hs.resize_right)
    -- swapping buffers between windows
    -- Mirrors smart-splits: at_edge = "stop", cursor_follows_swapped_bufs = true.
    local function swap_buf(dir_key)
      return function()
        local cur_win = vim.api.nvim_get_current_win()
        local cur_buf = vim.api.nvim_win_get_buf(cur_win)
        local cur_pos = vim.api.nvim_win_get_cursor(cur_win)
        vim.cmd("wincmd " .. dir_key)
        local target_win = vim.api.nvim_get_current_win()
        if target_win == cur_win then return end -- at edge: stop
        local target_buf = vim.api.nvim_win_get_buf(target_win)
        vim.api.nvim_win_set_buf(cur_win, target_buf)
        vim.api.nvim_win_set_buf(target_win, cur_buf)
        -- cursor follows the swapped buffer (target_win is now focused)
        pcall(vim.api.nvim_win_set_cursor, target_win, cur_pos)
      end
    end
    vim.keymap.set("n", "<C-w>H", swap_buf("h"))
    vim.keymap.set("n", "<C-w>J", swap_buf("j"))
    vim.keymap.set("n", "<C-w>K", swap_buf("k"))
    vim.keymap.set("n", "<C-w>L", swap_buf("l"))
  end,
}
