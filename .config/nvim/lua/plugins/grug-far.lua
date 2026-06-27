-- https://github.com/MagicDuck/grug-far.nvim
return {
  "MagicDuck/grug-far.nvim",
  event = "VeryLazy",
  config = function()
    require("grug-far").setup({
      keymaps = {
        close = { n = "q" },
      },
    })

    vim.keymap.set("n", "<leader>sr", function()
      require("grug-far").open()
    end, { desc = "Search/replace" })

    vim.keymap.set("x", "<leader>sr", function()
      require("grug-far").with_visual_selection()
    end, { desc = "Search/replace selection" })

    vim.keymap.set("n", "<leader>sw", function()
      require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
    end, { desc = "Search/replace word" })

    vim.keymap.set("n", "<leader>sf", function()
      require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
    end, { desc = "Search/replace current file" })
  end,
}
