return {
  {
    "https://github.com/FabijanZulj/blame.nvim",
    lazy = false,
    config = function()
      require("blame").setup({
        blame_options = { "-w" },
        date_format = "%Y/%m/%d %H:%M",
        -- Default mappings:
        mappings = {
          commit_info = "i",
          stack_push = "<TAB>",
          stack_pop = "<BS>",
          show_commit = "<CR>",
          close = { "<esc>", "q" },
          copy_hash = "y",
          open_in_browser = "o",
        },
      })
      vim.keymap.set("n", "<leader>gb", "<cmd>BlameToggle<cr>", { desc = "Toggle git blame" })
    end,
  },
}
