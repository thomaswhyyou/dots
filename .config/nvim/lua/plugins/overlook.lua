-- https://github.com/WilliamHsieh/overlook.nvim
return {
  "WilliamHsieh/overlook.nvim",
  -- enabled = false,
  config = function()
    require("overlook").setup({
      ui = {
        size_ratio = 1, -- Default size ratio (0.0 to 1.0)
        row_offset = 0,
        col_offset = 0,
        min_width = 120,
      },
    })

    local api = require("overlook.api")
    vim.keymap.set("n", "gD", api.peek_definition, { desc = "Peek definition" })
    vim.keymap.set("n", "gpd", api.peek_definition, { desc = "Peek definition" })

    vim.keymap.set("n", "gpp", api.peek_cursor, { desc = "Peek cursor" })
    vim.keymap.set("n", "gpu", api.restore_popup, { desc = "Restore last popup" })
    vim.keymap.set("n", "gpU", api.restore_all_popups, { desc = "Restore all popups" })
    vim.keymap.set("n", "gpc", api.close_all, { desc = "Close all popups" })
    vim.keymap.set("n", "gpf", api.switch_focus, { desc = "Switch focus" })
    vim.keymap.set("n", "gps", api.open_in_split, { desc = "Open popup in split" })
    vim.keymap.set("n", "gpv", api.open_in_vsplit, { desc = "Open popup in vsplit" })
    vim.keymap.set("n", "gpt", api.open_in_tab, { desc = "Open popup in tab" })
    vim.keymap.set("n", "gpo", api.open_in_original_window, { desc = "Open popup in curr window" })
  end,
}
