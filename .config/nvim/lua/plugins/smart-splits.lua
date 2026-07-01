-- Note: Also supports navigation between Neovim and tmux split panes.
return {
  "https://github.com/mrjones2014/smart-splits.nvim",
  config = function()
    local ss = require("smart-splits")
    ss.setup({
      at_edge = "stop",
      cursor_follows_swapped_bufs = true,
    })

    -- moving between splits
    local function maybe_move(move)
      return function()
        if vim.w.is_overlook_popup then return end
        if vim.w.snacks_main then return end
        move()
      end
    end
    vim.keymap.set({ "n", "t" }, "<C-h>", maybe_move(ss.move_cursor_left))
    vim.keymap.set({ "n", "t" }, "<C-j>", maybe_move(ss.move_cursor_down))
    vim.keymap.set({ "n", "t" }, "<C-k>", maybe_move(ss.move_cursor_up))
    vim.keymap.set({ "n", "t" }, "<C-l>", maybe_move(ss.move_cursor_right))
    vim.keymap.set({ "n", "t" }, "<C-\\>", maybe_move(ss.move_cursor_previous))
    -- resizing splits
    vim.keymap.set("n", "<A-h>", ss.resize_left)
    vim.keymap.set("n", "<A-j>", ss.resize_down)
    vim.keymap.set("n", "<A-k>", ss.resize_up)
    vim.keymap.set("n", "<A-l>", ss.resize_right)
    -- swapping buffers between windows
    vim.keymap.set("n", "<C-w>H", ss.swap_buf_left)
    vim.keymap.set("n", "<C-w>J", ss.swap_buf_down)
    vim.keymap.set("n", "<C-w>K", ss.swap_buf_up)
    vim.keymap.set("n", "<C-w>L", ss.swap_buf_right)
  end,
}
