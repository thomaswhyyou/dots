-- https://github.com/khoido2003/monokai-v2.nvim
-- IMPORTANT: Must run :MonokaiCache clear command after making any changes.
return {
  "khoido2003/monokai-v2.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  priority = 1000,
  opts = {
    -- classic | octagon | pro | machine | ristretto | spectrum
    filter = "pro",
    background_clear = {
      "which-key",
    },
    override = function(c)
      local ch = require("mini.colors")

      return {
        -- Make ColorColumn slightly darker than the background
        ColorColumn = {
          bg = ch.modify_channel(c.editor.background, "lightness", function(l)
            return l - 1
          end),
        },
        -- Popup window title
        FloatTitle = { fg = c.base.yellow, bg = c.base.dimmed5 },
        -- Make directories cyan in Oil
        Directory = { fg = c.base.cyan, bg = c.editor.background, bold = true },
        -- Keep CurSearch identical to IncSearch
        CurSearch = { link = "IncSearch" },
        -- Make the cursor line number brighter
        CursorLineNr = { link = "Todo" },
        -- Make Search highlights brighter
        Search = { bg = c.base.dimmed3, fg = c.base.white },

        -- Incline: window titles
        InclineNormal = { fg = c.base.yellow, bg = c.base.dimmed5, bold = true },
        InclineNormalNC = { bg = c.base.dimmed5 },
      }
    end,
  },
  init = function()
    vim.cmd.colorscheme("monokai-v2")
  end,
}
