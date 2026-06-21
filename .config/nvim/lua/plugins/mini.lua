-- https://github.com/nvim-mini/mini.nvim/
-- https://nvim-mini.org/mini.nvim/
return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
    -- require("mini.ai").setup()

    -- https://nvim-mini.org/mini.nvim/readmes/mini-bufremove.html
    require("mini.bufremove").setup()

    -- https://nvim-mini.org/mini.nvim/readmes/mini-bracketed.html
    require("mini.bracketed").setup()

    -- https://nvim-mini.org/mini.nvim/readmes/mini-pairs.html
    require("mini.pairs").setup()

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

    -- https://nvim-mini.org/mini.nvim/readmes/mini-indentscope.html
    require("mini.indentscope").setup({
      draw = {
        animation = require("mini.indentscope").gen_animation.none(),
      },
      options = {
        -- Max number of lines above or below within which scope is computed
        n_lines = 80,
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
  end,
}
