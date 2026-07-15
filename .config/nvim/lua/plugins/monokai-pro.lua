-- IMPORTANT:
-- Must run :MonokaiCache clear command after making any changes.
return {
  "https://github.com/khoido2003/monokai-v2.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  priority = 1000,
  opts = {
    -- classic | octagon | pro | machine | ristretto | spectrum
    filter = "pro",
    background_clear = {
      "which-key",
      "snacks",
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
        CursorLineNr = { fg = c.base.yellow },
        -- Make Search highlights brighter
        Search = { bg = c.base.dimmed3, fg = c.base.white },
        -- Winbar (dropbar) text: bright in the focused window, dimmed otherwise
        WinBar = { fg = c.base.dimmed1, bg = c.editor.background },
        WinBarNC = { fg = c.base.dimmed3, bg = c.editor.background },
        -- Health check section delimiters
        healthSectionDelim = { link = "CursorLine" },

        -- incline: window titles
        InclineNormal = { fg = c.base.yellow, bg = c.base.dimmed5, bold = true },
        InclineNormalNC = { bg = c.base.dimmed5 },
        -- mini.diff: sign colors (link them to monokai defined colors)
        MiniDiffSignAdd = { link = "DiffAdded" },
        MiniDiffSignChange = { link = "DiffChanged" },
        MiniDiffSignDelete = { link = "DiffRemoved" },
        -- lualine: diff colors (link them to monokai defined colors)
        LuaLineDiffAdd = { link = "DiffAdded" },
        LuaLineDiffChange = { link = "DiffChanged" },
        LuaLineDiffDelete = { link = "DiffRemoved" },
        -- flash: use Hop's bold magenta for the jump label
        FlashLabel = { fg = "#ff007c", bg = c.editor.background, bold = true },
        FlashCurrent = { link = "CurSearch" },
        -- multicursor:
        MultiCursorSign = { fg = c.base.dimmed3, bg = c.editor.background }
      }
    end,
  },
  init = function()
    vim.cmd.colorscheme("monokai-v2")
  end,
}
