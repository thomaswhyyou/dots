-- https://github.com/vim-test/vim-test
return {
  "vim-test/vim-test",
  dependencies = {
    "akinsho/toggleterm.nvim",
  },
  init = function()
    vim.g["test#strategy"] = "toggleterm"
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
    -- { "<leader>tf", "<cmd>TestFile<CR>" },
    -- { "<leader>ts", "<cmd>TestSuite<CR>" },
    -- { "<leader>tl", "<cmd>TestLast<CR>" },
    -- { "<leader>tg", "<cmd>TestVisit<CR>" },
  },
}
