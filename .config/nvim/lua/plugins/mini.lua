-- https://github.com/nvim-mini/mini.nvim/
return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
    -- require("mini.ai").setup()

    require("mini.bufremove").setup()
    require("mini.bracketed").setup()
    require("mini.pairs").setup()

    require("mini.git").setup()
    require("mini.diff").setup({
      view = {
        style = "sign",
        signs = { add = "+", change = "~", delete = "_" },
      },
    })

    require("mini.notify").setup({
      window = {
        config = { anchor = "SE", row = vim.o.lines - 1 },
      },
    })
    vim.keymap.set("n", "<leader>n", function()
      -- Toggle: if the history window is already open, close it
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

    require("mini.indentscope").setup({
      draw = {
        animation = require("mini.indentscope").gen_animation.none(),
      },
      options = {
        -- Max number of lines above or below within which scope is computed
        n_lines = 100,
      },
      symbol = "▏",
    })
    vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = "Comment" })

    --- mini.hipatterns ---

    -- require('mini.hipatterns').setup({
    --   highlighters = {
    --     -- Highlight markdown horizontal rules (3+ dashes)
    --     markdown_hr = {
    --       pattern = '^%-%-%-+%s*$',
    --       group = 'MiniHipatternsMarkdownHR',
    --     },
    --   },
    -- })
    -- -- Define the highlight group with blue color
    -- vim.api.nvim_set_hl(0, 'MiniHipatternsMarkdownHR', { fg = '#6495ED', bold = true })

    -- require('mini.hipatterns').setup({
    --   highlighters = {
    --     triple_dash = {
    --       pattern = function(buf_id)
    --         return '^[%s#/]*()%-%-%-()'
    --       end,
    --       group = '',
    --       extmark_opts = function(buf_id, match, data)
    --         return {
    --           end_row = data.line - 1,
    --           end_col = 0,
    --           hl_eol = true,
    --           hl_group = 'MiniHipatternsTripleDash',
    --           line_hl_group = 'MiniHipatternsTripleDash',
    --           priority = 200,
    --         }
    --       end,
    --     },
    --   },
    -- })
    -- vim.api.nvim_set_hl(0, 'MiniHipatternsTripleDash', { fg = '#6495ED' })

    -- require("mini.jump").setup()


    --- mini.statusline ---
    -- local MiniStatusline = require("mini.statusline")
    -- require("mini.statusline").setup({
    --   content = {
    --     active = function()
    --       local git = MiniStatusline.section_git()
    --       local diff = MiniStatusline.section_diff()
    --       local diagnostics = MiniStatusline.section_diagnostics()
    --       local lsp = MiniStatusline.section_lsp()
    --
    --       return MiniStatusline.combine_groups({
    --         { content = git, hl = "MiniStatuslineDevinfo" },
    --         { content = diff, hl = "MiniStatuslineDevinfo" },
    --         { content = diagnostics, hl = "MiniStatuslineDevinfo" },
    --         { content = lsp, hl = "MiniStatuslineDevinfo", right = true },
    --       })
    --     end,
    --   },
    -- })

    --- statusline
    require("mini.statusline").setup()

    -- --- statusline
    -- local statusline = require("mini.statusline")
    -- statusline.setup({
    --   content = {
    --     active = function()
    --       local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
    --       local git = statusline.section_git({ trunc_width = 40 })
    --       local diff = statusline.section_diff({ trunc_width = 75 })
    --       local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
    --       local lsp = statusline.section_lsp({ trunc_width = 75 })
    --       local filename = statusline.section_filename({ trunc_width = 140 })
    --       local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
    --       local location = statusline.section_location({ trunc_width = 75 })
    --       local search = statusline.section_searchcount({ trunc_width = 75 })
    --
    --       return statusline.combine_groups({
    --         { hl = mode_hl, strings = { mode } },
    --         { hl = "MiniStatuslineDevinfo", strings = { lsp } },
    --         "%<", -- Mark general truncate point
    --         { hl = "MiniStatuslineFilename", strings = { filename, git, diff } },
    --         "%=", -- End left alignment
    --         { hl = "MiniStatuslineFileinfo", strings = { diagnostics } },
    --         { hl = mode_hl, strings = { search } },
    --       })
    --     end,
    --   },
    -- })

    -- -- Evil-lualine-ish palette (gruvbox-y; tweak to taste)
    -- local c = {
    --   bg       = "#202328",
    --   fg       = "#bbc2cf",
    --   yellow   = "#ECBE7B",
    --   cyan     = "#008080",
    --   darkblue = "#081633",
    --   green    = "#98be65",
    --   orange   = "#FF8800",
    --   violet   = "#a9a1e1",
    --   magenta  = "#c678dd",
    --   blue     = "#51afef",
    --   red      = "#ec5f67",
    -- }
    --
    -- -- Mode block colors (left/right edges in evil_lualine)
    -- vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal",  { fg = c.bg, bg = c.green,  bold = true })
    -- vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert",  { fg = c.bg, bg = c.blue,   bold = true })
    -- vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual",  { fg = c.bg, bg = c.magenta,bold = true })
    -- vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { fg = c.bg, bg = c.red,    bold = true })
    -- vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { fg = c.bg, bg = c.yellow, bold = true })
    -- vim.api.nvim_set_hl(0, "MiniStatuslineModeOther",   { fg = c.bg, bg = c.cyan,   bold = true })
    --
    -- -- Middle sections
    -- vim.api.nvim_set_hl(0, "MiniStatuslineDevinfo",  { fg = c.fg,     bg = "#3b4048" })
    -- vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { fg = c.violet, bg = c.bg, bold = true })
    -- vim.api.nvim_set_hl(0, "MiniStatuslineFileinfo", { fg = c.fg,     bg = "#3b4048" })
    -- vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { fg = c.fg,     bg = c.bg })
  end,
}
