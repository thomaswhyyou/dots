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
        -- Color Oil directories cyan
        Directory = { fg = c.base.cyan, bg = c.editor.background, bold = true },
        -- Keep CurSearch identical to IncSearch
        CurSearch = { link = "IncSearch" },
        -- Make the cursor line number brighter
        CursorLineNr = { link = "Todo" },
        -- Make Search highlights brighter
        Search = { bg = c.base.dimmed3, fg = c.base.white },
        -- Incline window title currently focused
        InclineNormal = { fg = c.base.dimmed5, bg = c.base.yellow, bold = true },
      }
    end,
  },
  init = function()
    vim.cmd.colorscheme("monokai-v2")
  end,
}
