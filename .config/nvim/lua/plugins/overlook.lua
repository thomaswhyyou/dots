-- https://github.com/WilliamHsieh/overlook.nvim
return {
  -- "WilliamHsieh/overlook.nvim",
  "thomaswhyyou/overlook.nvim",
  config = function()
    require("overlook").setup({
      ui = {
        title_pos = "left", -- added in the fork
        size_ratio = 1,
        row_offset = 0,
        col_offset = 0,
        min_width = 120,
      },
    })

    -- -- Overlook hardcodes `title_pos = "center"` (popup.lua) with no config
    -- -- option. Wrap popup.new so each popup left-aligns its title after opening.
    -- local popup = require("overlook.popup")
    -- local orig_new = popup.new
    -- popup.new = function(...)
    --   local p = orig_new(...)
    --   if type(p) == "table" then
    --     local orig_open = p.open
    --     p.open = function(self, enter)
    --       local ok = orig_open(self, enter)
    --       if ok and self.winid and vim.api.nvim_win_is_valid(self.winid) then
    --         local cfg = vim.api.nvim_win_get_config(self.winid)
    --         pcall(vim.api.nvim_win_set_config, self.winid, {
    --           title = cfg.title,
    --           title_pos = "left",
    --         })
    --       end
    --       return ok
    --     end
    --   end
    --   return p
    -- end

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
