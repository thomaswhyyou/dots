-- https://nvim-mini.org/mini.nvim/
return {
  "https://github.com/nvim-mini/mini.nvim",
  version = false,
  config = function()
    -- https://nvim-mini.org/mini.nvim/readmes/mini-ai.html
    require("mini.ai").setup()

    -- https://nvim-mini.org/mini.nvim/readmes/mini-align.html
    require("mini.align").setup()

    -- https://nvim-mini.org/mini.nvim/readmes/mini-surround.html
    require("mini.surround").setup()

    -- https://nvim-mini.org/mini.nvim/readmes/mini-pairs.html
    require("mini.pairs").setup({
      -- Only auto-pair at end-of-line. `neigh_pattern` matches the chars around
      -- the cursor; end-of-line is `\n`, so `[^\\]\n` = "not after a backslash,
      -- nothing ahead". `%a` also excludes quotes inside words (e.g. don't).
      mappings = {
        ["("] = { neigh_pattern = "[^\\]\n" },
        ["["] = { neigh_pattern = "[^\\]\n" },
        ["{"] = { neigh_pattern = "[^\\]\n" },
        ['"'] = { neigh_pattern = "[^\\]\n" },
        ["'"] = { neigh_pattern = "[^%a\\]\n" },
        ["`"] = { neigh_pattern = "[^\\]\n" },
      },
    })

    -- https://nvim-mini.org/mini.nvim/readmes/mini-bufremove.html
    require("mini.bufremove").setup()

    -- https://nvim-mini.org/mini.nvim/readmes/mini-bracketed.html
    require("mini.bracketed").setup()

    -- https://nvim-mini.org/mini.nvim/readmes/mini-git.html
    require("mini.git").setup()

    -- https://nvim-mini.org/mini.nvim/readmes/mini-diff.html
    require("mini.diff").setup({
      view = {
        style = "sign",
        signs = { add = "+", change = "~", delete = "_" },
      },
    })

    -- https://nvim-mini.org/mini.nvim/readmes/mini-notify.html
    require("mini.notify").setup({
      lsp_progress = {
        enable = false,
      },
      window = {
        config = { anchor = "SE", row = vim.o.lines - 1 },
      },
    })
    -- Toggle notification history
    vim.keymap.set("n", "<leader>n", function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "mininotify-history" then
          vim.api.nvim_win_close(win, true)
          return
        end
      end
      vim.cmd("botright 20split") -- full-width split, 20 rows tall, at the bottom
      require("mini.notify").show_history() -- swaps the history buffer into that new split
    end, { desc = "Notification history" })
    -- Clear all notifications
    vim.keymap.set("n", "<leader>un", function()
      require("mini.notify").clear()
    end, { desc = "Dismiss All Notifications" })

    -- https://nvim-mini.org/mini.nvim/readmes/mini-indentscope.html
    require("mini.indentscope").setup({
      symbol = "▏",
      draw = {
        animation = require("mini.indentscope").gen_animation.none(),
      },
    })
    vim.g.miniindentscope_disable = true -- off by default
    vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = "Comment" })

    -- https://nvim-mini.org/mini.nvim/readmes/mini-hipatterns.html
    require("mini.hipatterns").setup({
      highlighters = {
        xxx = { pattern = "%f[%w]()XXX()%f[%W]", group = "MiniHipatternsXXX" },
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsXXX" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsXXX" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsXXX" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsXXX" },
        triple_dash = { pattern = "^()%s*%-%-%-.*()$", group = "MiniHipatternsDDD" },
      },
    })
    vim.api.nvim_set_hl(0, "MiniHipatternsXXX", { fg = "#FFFFFF", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsDDD", { fg = "#78dce8" })
  end,
}

-- No-go:
-- mini.clue: whick-key
-- mini.cmdline: blink
-- mini.deps: vim.pack
-- mini.jump: flash
-- mini.jump2d: flash
-- mini.pick: fzf-lua
-- mini.statusline: lualine
-- mini.tabline: lualine
