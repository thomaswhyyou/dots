return {
  {
    "https://github.com/jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      -- Add cursor by matching word/selection (Shift reverses direction).
      vim.keymap.set({ "n", "x" }, "<C-n>", function() mc.matchAddCursor(1) end)
      vim.keymap.set({ "n", "x" }, "<C-S-n>", function() mc.matchAddCursor(-1) end)
      -- Skip a match instead of adding (Alt = skip; Shift reverses direction).
      vim.keymap.set({ "n", "x" }, "<M-n>", function() mc.matchSkipCursor(1) end)
      vim.keymap.set({ "n", "x" }, "<M-S-n>", function() mc.matchSkipCursor(-1) end)

      -- Append/insert for each line of visual selections.
      -- Similar to block selection insertion.
      vim.keymap.set("x", "I", mc.insertVisual)
      vim.keymap.set("x", "A", mc.appendVisual)

      -- Mappings defined in a keymap layer only apply when there are
      -- multiple cursors. This lets you have overlapping mappings.
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one.
        layerSet({ "n", "x" }, "<left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<right>", mc.nextCursor)

        -- Delete the main cursor.
        layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

        -- Enable and clear cursors using escape.
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
    end,
  },
}
