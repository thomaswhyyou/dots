-- https://github.com/folke/flash.nvim
return {
  "folke/flash.nvim",
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
    })

    -- Use Hop's bold magenta for the jump label
    vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#ff007c", bold = true })
    -- Match the current search match color
    vim.api.nvim_set_hl(0, "FlashCurrent", { link = "CurSearch" })
  end,
}
