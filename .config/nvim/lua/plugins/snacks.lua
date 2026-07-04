return {
  "https://github.com/folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  config = function()
    local s = require("snacks")

    s.setup({
      bigfile = {},
      zen = {
        toggles = {
          dim = false,
        },
        win = {
          zindex = 60, -- Higher than incline displays
          minimal = true, -- Strip UI chrome (numbers, signcolumn, statuscolumn, folds)
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
      lazygit = {
        win = {
          position = "float",
        },
      },
    })

    -- Lazygit
    vim.keymap.set("n", "<leader>gg", function() s.lazygit() end, { desc = "Lazygit" })

    -- Zen toggle
    vim.keymap.set("n", "<leader>uz", function() s.zen() end, { desc = "Toggle Zen Mode" })

    -- Diagnostics toggle
    vim.keymap.set("n", "<leader>ud", function() s.toggle.diagnostics():toggle() end, { desc = "Toggle Diagnostics" })

    -- Indent guide toggle (mini.indentscope)
    s.toggle
      .new({
        name = "Indent Guide",
        get = function() return not vim.g.miniindentscope_disable end,
        set = function(on)
          local ok, mi = pcall(require, "mini.indentscope")
          if not ok then return end
          vim.g.miniindentscope_disable = not on
          if on then mi.draw() else mi.undraw() end
        end,
      })
      :map("<leader>ug")

    -- Terminal toggle
    -- Ctrl+/ arrives as <C-/> in modern terminals (CSI-u/Kitty protocol) but as
    -- <C-_> (0x1F) in legacy ones, so bind both to cover either encoding.
    vim.keymap.set({ "n", "t" }, "<C-/>", s.terminal.toggle, { noremap = true, silent = true })
    vim.keymap.set({ "n", "t" }, "<C-_>", s.terminal.toggle, { noremap = true, silent = true })

    -- Git browse permalink (open in browser / copy URL)
    vim.keymap.set({ "n", "x" }, "<leader>gB", function() s.gitbrowse({ what = "permalink" }) end, { desc = "Git Permalink (open)" })
    vim.keymap.set({ "n", "x" }, "<leader>gY", function()
      s.gitbrowse({ what = "permalink", open = function(url) vim.fn.setreg("+", url) end, notify = false })
    end, { desc = "Git Permalink (copy)" })
  end,
}
