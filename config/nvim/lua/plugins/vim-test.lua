return {
  "https://github.com/vim-test/vim-test",
  init = function()
    vim.g["test#custom_strategies"] = {
      snacks = function(cmd)
        require("snacks").terminal.open(cmd, {
          -- Non-interactive: no auto-insert and, crucially, no auto-close so
          -- the test output stays on screen after the run finishes.
          interactive = false,
          win = { position = "bottom" },
        })
      end,
    }
    vim.g["test#strategy"] = pcall(require, "snacks") and "snacks" or "neovim"

    vim.keymap.set("n", "<leader>tn", "<cmd>TestNearest<CR>", { desc = "Test nearest" })
    vim.keymap.set("n", "<leader>tf", "<cmd>TestFile<CR>", { desc = "Test file" })
    vim.keymap.set("n", "<leader>ts", "<cmd>TestSuite<CR>", { desc = "Test suite" })
    vim.keymap.set("n", "<leader>tl", "<cmd>TestLast<CR>", { desc = "Test last" })
    vim.keymap.set("n", "<leader>tg", "<cmd>TestVisit<CR>", { desc = "Go to last test" })
  end,
  cmd = {
    "TestNearest",
    "TestFile",
    "TestSuite",
    "TestLast",
    "TestVisit",
  },
}
