-- https://github.com/stevearc/quicker.nvim
return {
  "stevearc/quicker.nvim",
  ft = "qf",
  config = function()
    require("quicker").setup({
      borders = {
        vert = "|",
      },
    })
  end,
}
