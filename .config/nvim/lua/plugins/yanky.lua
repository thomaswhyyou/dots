return {
  "https://github.com/gbprod/yanky.nvim",
  config = function()
    require("yanky").setup({
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 200,
      },
    })
    -- Preserve cursor position on yank
    vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)")
  end,
}
