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
  end,
}
