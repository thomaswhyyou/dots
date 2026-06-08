-- https://github.com/mrjones2014/smart-splits.nvim
-- Also supports seamless navigation between Neovim and tmux split panes.
return {
  "mrjones2014/smart-splits.nvim",
  config = function()
    require("smart-splits").setup({
      at_edge = "stop",
      cursor_follows_swapped_bufs = true,
    })
    -- -- resizing splits
    -- vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
    -- vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
    -- vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
    -- vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)
    -- moving between splits
    vim.keymap.set({ "n", "t" }, "<C-h>", require("smart-splits").move_cursor_left)
    vim.keymap.set({ "n", "t" }, "<C-j>", require("smart-splits").move_cursor_down)
    vim.keymap.set({ "n", "t" }, "<C-k>", require("smart-splits").move_cursor_up)
    vim.keymap.set({ "n", "t" }, "<C-l>", require("smart-splits").move_cursor_right)
    vim.keymap.set({ "n", "t" }, "<C-\\>", require("smart-splits").move_cursor_previous)
    -- swapping buffers between windows
    vim.keymap.set("n", "<C-w>H", require("smart-splits").swap_buf_left)
    vim.keymap.set("n", "<C-w>J", require("smart-splits").swap_buf_down)
    vim.keymap.set("n", "<C-w>K", require("smart-splits").swap_buf_up)
    vim.keymap.set("n", "<C-w>L", require("smart-splits").swap_buf_right)
  end,
}
