-- https://github.com/gbprod/yanky.nvim
return {
  "gbprod/yanky.nvim",
  config = function()
    require("yanky").setup({
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 200,
      },
    })
    vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)")

    -- YankyPut
    -- YankyYanked
  end,
}
