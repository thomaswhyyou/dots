-- https://github.com/folke/flash.nvim/blob/3c942666f115e2811e959eabbdd361a025db8b63/lua/flash/highlight.lua#L23-L31
local function set_highlights()
  -- Dimmed but not bolded or italicized in the background
  local hl_comment = vim.api.nvim_get_hl(0, { name = "Comment" })
  vim.api.nvim_set_hl(0, "FlashBackdrop", { fg = hl_comment.fg, italic = false })

  -- Use Hop's bold magenta for the jump label
  vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#ff007c", bold = true })

  -- Use the search bg (default), but the identifier fg (brighter)
  local hl_search = vim.api.nvim_get_hl(0, { name = "Search" })
  local hl_identifier = vim.api.nvim_get_hl(0, { name = "Identifier" })
  vim.api.nvim_set_hl(0, "FlashMatch", { bg = hl_search.bg, fg = hl_identifier.fg })
end

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
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })
    set_highlights()

    require("flash").setup({
      label = {
        current = false,
        after = false,
        before = true,
        style = "overlay", -- "eol" | "overlay" | "right_align" | "inline"
        min_pattern_length = 2,
      },
      -- modes = {
      --   search = {
      --     enabled = true,
      --     label = {
      --       style = "eol",
      --     },
      --     -- highlight = { backdrop = true },
      --   },
      -- },
    })
  end,
}
