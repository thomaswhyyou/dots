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
  end,
  cmd = {
    "TestNearest",
    "TestFile",
    "TestSuite",
    "TestLast",
    "TestVisit",
  },
  keys = {
    { "<leader>tn", "<cmd>TestNearest<CR>" },
    { "<leader>tf", "<cmd>TestFile<CR>" },
    { "<leader>ts", "<cmd>TestSuite<CR>" },
    { "<leader>tl", "<cmd>TestLast<CR>" },
    { "<leader>tg", "<cmd>TestVisit<CR>" },
  },
}
