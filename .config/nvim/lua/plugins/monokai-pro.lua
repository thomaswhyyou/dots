-- -- https://github.com/loctvl842/monokai-pro.nvim
-- return {
--   "loctvl842/monokai-pro.nvim",
--   lazy = false,
--   priority = 1000,
--   opts = {
--     -- filter = classic | octagon | pro | machine | ristretto | spectrum
--     day_night = {
--       enable = true,
--       day_filter = "machine",
--       night_filter = "machine",
--     },
--     background_clear = {
--       "which-key",
--     },
--     override = function(c)
--       local mc = require("mini.colors")
--
--       return {
--         -- vim.o.colorcolumn, slightly darker than the bg color
--         ColorColumn = {
--           bg = mc.modify_channel(c.editor.background, "lightness", function(l)
--             return l - 1
--           end),
--         },
--         --
--         Directory = { fg = c.base.cyan, bg = c.editor.background, bold = true },
--
--         -- Search = { bg = c.base.dimmed3 },
--       }
--     end,
--   },
--   init = function()
--     vim.cmd([[colorscheme monokai-pro]])
--   end,
-- }

-- https://github.com/khoido2003/monokai-v2.nvim
-- IMPORTANT: Must run :MonokaiCache clear command after making any changes.
return {
  "khoido2003/monokai-v2.nvim",
  priority = 1000,
  opts = {
    -- classic | octagon | pro | machine | ristretto | spectrum
    filter = "pro",
    background_clear = {
      "which-key",
    },
    override = function(c)
      local mc = require("mini.colors")
      -- local ch = require("monokai-v2.color_helper")

      return {
        -- Make ColorColumn slightly darker than the background
        ColorColumn = {
          bg = mc.modify_channel(c.editor.background, "lightness", function(l)
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
        -- Search = { bg = c.base.dimmed1, fg = c.base.black, bold = true },

        -- Search = { bg = c.base.dimmed3, fg = c.base.white },
        -- Search = { bg = ch.blend(c.base.yellow, 0.35, c.editor.background) },
        -- Search = { bg = c.base.dimmed3 },
        -- Search = { bg = c.base.dimmed1, fg = c.base.black },
      }
    end,
  },
  init = function()
    vim.cmd.colorscheme("monokai-v2")
  end,
}
