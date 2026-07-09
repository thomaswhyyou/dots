return {
  "https://github.com/folke/flash.nvim",
  event = "VeryLazy",
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
  },
  config = function()
    require("flash").setup({
      label = {
        current = false,
        after = false,
        before = true,
        style = "overlay", -- "eol" | "overlay" | "right_align" | "inline"
        min_pattern_length = 2,
      },
      modes = {
        search = {
          enabled = true,
          label = {
            style = "eol",
          },
        },
      },
    })
  end,
}
