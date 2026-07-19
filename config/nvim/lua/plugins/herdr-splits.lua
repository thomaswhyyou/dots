return {
  "https://github.com/lmilojevicc/herdr-splits.nvim",
  cond = vim.env.HERDR_ENV == "1",
  build = 'lua require("herdr-splits").sync_herdr()',
  config = function()
    local hs = require("herdr-splits")
    hs.setup({ auto_sync_herdr = true })

    -- moving between splits / herdr panes
    vim.keymap.set({ "n", "t" }, "<C-h>", hs.move_cursor_left, { desc = "Navigate left" })
    vim.keymap.set({ "n", "t" }, "<C-j>", hs.move_cursor_down, { desc = "Navigate down" })
    vim.keymap.set({ "n", "t" }, "<C-k>", hs.move_cursor_up, { desc = "Navigate up" })
    vim.keymap.set({ "n", "t" }, "<C-l>", hs.move_cursor_right, { desc = "Navigate right" })
    -- resizing splits
    vim.keymap.set("n", "<M-h>", hs.resize_left, { desc = "Resize left" })
    vim.keymap.set("n", "<M-j>", hs.resize_down, { desc = "Resize down" })
    vim.keymap.set("n", "<M-k>", hs.resize_up, { desc = "Resize up" })
    vim.keymap.set("n", "<M-l>", hs.resize_right, { desc = "Resize right" })
  end,
}
