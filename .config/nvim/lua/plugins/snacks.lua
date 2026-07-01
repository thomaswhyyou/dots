return {
  "https://github.com/folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  config = function()
    local s = require("snacks")

    s.setup({
      zen = {
        toggles = {
          dim = false,
        },
        win = {
          zindex = 60, -- Higher than incline displays
          minimal = true, -- Strip UI chrome (numbers, signcolumn, statuscolumn, folds) for a distraction-free window.
          width = 120,
          backdrop = {
            transparent = false,
            blend = 0,
            -- Use the darkened background for the terminal window.
            win = { wo = { winhighlight = "Normal:NormalFloat" } },
          },
        },
      },

      terminal = {
        win = {
          position = "bottom",
          wo = {
            -- Hide the cwd/title row Snacks puts in the winbar.
            winbar = "",
            -- Use the darkened background for the terminal window.
            winhighlight = "Normal:NormalFloat",
          },
        },
      },
    })

    -- Zen toggle
    vim.keymap.set("n", "<leader>uz", function() s.zen() end, { desc = "Toggle Zen Mode" })

    -- Diagnostics toggle
    vim.keymap.set("n", "<leader>ud", function() s.toggle.diagnostics():toggle() end, { desc = "Toggle Diagnostics" })

    -- Terminal toggle
    -- Ctrl+/ arrives as <C-/> in modern terminals (CSI-u/Kitty protocol) but as
    -- <C-_> (0x1F) in legacy ones, so bind both to cover either encoding.
    vim.keymap.set({ "n", "t" }, "<C-/>", s.terminal.toggle, { noremap = true, silent = true })
    vim.keymap.set({ "n", "t" }, "<C-_>", s.terminal.toggle, { noremap = true, silent = true })

  end,
}
