-- https://github.com/nvim-mini/mini.nvim/
return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
    -- require("mini.notify").setup()
    -- require("mini.ai").setup()

    -- require('mini.indentscope').setup({
    --   symbol = '╎',
    --   draw = {
    --     -- Delay (in ms) between event and start of drawing scope indicator
    --     delay = 100,
    --     animation = require('mini.indentscope').gen_animation.none(),
    --
    --     -- Symbol priority. Increase to display on top of more symbols.
    --     priority = 2,
    --   },
    -- })

    require("mini.bracketed").setup()
    require("mini.bufremove").setup()

    -- Per-window buffer history + vim-bufkill-style :BB/:BF/:BA
    -- Pairs with mini.bufremove for :BD/:BUN/:BW.

    local hist = {} -- hist[winid] = { bufs = {b1, b2, ...}, idx = N }
    local navigating = false -- suppress recording while we move via :BB/:BF

    local function get(win)
      hist[win] = hist[win] or { bufs = {}, idx = 0 }
      return hist[win]
    end

    local function compact(h)
      local cur = h.bufs[h.idx]
      local kept = {}
      for _, b in ipairs(h.bufs) do
        if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted then
          kept[#kept + 1] = b
        end
      end
      h.bufs, h.idx = kept, 1
      for i, b in ipairs(kept) do
        if b == cur then
          h.idx = i
          break
        end
      end
    end

    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function(args)
        if navigating then
          return
        end
        if not vim.bo[args.buf].buflisted then
          return
        end
        local h = get(vim.api.nvim_get_current_win())
        if h.bufs[h.idx] == args.buf then
          return
        end
        for i = #h.bufs, h.idx + 1, -1 do
          h.bufs[i] = nil
        end -- drop forward
        h.bufs[#h.bufs + 1] = args.buf
        h.idx = #h.bufs
      end,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
      callback = function(args)
        hist[tonumber(args.match)] = nil
      end,
    })

    local function move(delta)
      local win = vim.api.nvim_get_current_win()
      local h = get(win)
      compact(h)
      local ni = h.idx + delta
      if ni < 1 or ni > #h.bufs then
        vim.notify("No " .. (delta < 0 and "previous" or "next") .. " buffer", vim.log.levels.INFO)
        return
      end
      h.idx = ni
      navigating = true
      vim.api.nvim_win_set_buf(win, h.bufs[ni])
      navigating = false
    end

    vim.api.nvim_create_user_command("BB", function()
      move(-1)
    end, {})
    vim.api.nvim_create_user_command("BF", function()
      move(1)
    end, {})

    vim.keymap.set("n", "<Tab>", "<Cmd>BF<CR>", { desc = "Buffer forward (history)" })
    vim.keymap.set("n", "<S-Tab>", "<Cmd>BB<CR>", { desc = "Buffer back (history)" })

    -- vim.api.nvim_create_user_command("BA", function()
    --   local col = vim.fn.virtcol(".")
    --   vim.cmd("buffer #")
    --   vim.fn.cursor(vim.fn.line("."), 1)
    --   vim.cmd("normal! " .. col .. "|")
    -- end, {})
    --
    -- -- Optional: make :BD switch to the previous buf in *this window's* history
    -- -- (vim-bufkill behavior) instead of mini.bufremove's alternate-buffer pick.
    -- vim.api.nvim_create_user_command("BD", function()
    --   local win = vim.api.nvim_get_current_win()
    --   local h = get(win)
    --   local doomed = vim.api.nvim_get_current_buf()
    --   compact(h)
    --   if h.idx > 1 then
    --     navigating = true
    --     vim.api.nvim_win_set_buf(win, h.bufs[h.idx - 1])
    --     navigating = false
    --   end
    --   require("mini.bufremove").delete(doomed, false)
    -- end, {})

    -- Partially. mini.bufremove is a drop-in replacement for the deletion half of vim-bufkill (:BD,
    -- :BUN, :BW), but it has no equivalent for the navigation half (:BB, :BF, :BA).
    --
    -- Mapping
    --
    -- vim-bufkill: :BD (delete, keep window)
    -- mini.bufremove: MiniBufremove.delete()
    -- ────────────────────────────────────────
    -- vim-bufkill: :BUN (unload, keep window)
    -- mini.bufremove: MiniBufremove.unshow() (closest — hides rather than unloads)
    -- ────────────────────────────────────────
    -- vim-bufkill: :BW (wipe, keep window)
    -- mini.bufremove: MiniBufremove.wipeout()
    -- ────────────────────────────────────────
    -- vim-bufkill: :BB / :BF (per-window buffer history)
    -- mini.bufremove: ❌ not provided
    -- ────────────────────────────────────────
    -- vim-bufkill: :BA (alternate buffer, preserve column)
    -- mini.bufremove: ❌ not provided (built-in <C-^> covers most of it, minus column preservation)
    --
    -- What's missing and why
    --
    -- :BB/:BF rely on a per-window buffer access history that vim-bufkill maintains via BufEnter
    -- autocmds. mini.bufremove only consults the alternate buffer / previous listed buffer at the moment
    --  of removal — it doesn't track history, doesn't expose a stack, and has no next/prev in history
    -- API.
    --
    -- If you want the full vim-bufkill experience, you'd need to either:
    -- 1. Keep vim-bufkill alongside mini.bufremove (use mini for :BD-style closing, bufkill just for
    -- :BB/:BF), or
    -- 2. Write a small autocmd that records BufEnter into a per-window list and exposes BB/BF commands
    -- yourself — it's ~30 lines of Lua but it's net-new code, not something mini.bufremove gives you.

    -- ⚠️ One thing to know about <Tab> in normal mode
    --
    -- In a terminal, <Tab> and <C-i> are the same byte — so mapping <Tab> shadows the built-in <C-i>
    -- (jump forward in the jumplist). If you use <C-o>/<C-i> to navigate jumps, you'll lose the forward
    -- half.
    --
    -- Options:
    --
    -- 1. Live with it. If you rarely use <C-i>, this is fine.
    -- 2. Remap <C-i> back explicitly so it still works:
    -- vim.keymap.set("n", "<C-i>", "<C-i>", { desc = "Jumplist forward" })
    -- 2. This only works in GUI Neovim or terminals that distinguish the two (kitty, WezTerm, Ghostty
    -- with csi-u / modifyOtherKeys enabled). In plain terminals it won't help.
    -- 3. Use a different binding that doesn't collide, e.g. <Leader><Tab> / <Leader><S-Tab>, or ]b / [b
    -- (though mini.bracketed already owns those for global-order navigation).

    ---

    require("mini.pairs").setup()

    -- Git
    require("mini.git").setup()
    require("mini.diff").setup({
      view = {
        -- TODO: Look into changing colors
        style = "sign",
        signs = { add = "+", change = "~", delete = "_" },
      },
    })

    -- Notifications
    require("mini.notify").setup()
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

    -- Cmdline
    -- require("mini.cmdline").setup()

    -- vim.keymap.set(
    --   "n",
    --   "<leader>n",
    --   require("mini.notify").show_history,
    --   { desc = "Show notification history" }
    -- )

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

    --- mini.statusline ---
    require("mini.statusline").setup()

    -- require("mini.jump").setup()

    -- MiniBracketed.buffer("forward", { wrap = false })
    -- MiniBracketed.

    -- TODO: Add a keybind to toggle this.
    require("mini.indentscope").setup({
      draw = {
        animation = require("mini.indentscope").gen_animation.none(),
      },
      options = {
        -- maximum number of lines above or below within which scope is computed
        n_lines = 100,

        -- -- whether to first check input line to be a border of adjacent scope.
        -- -- use it if you want to place cursor on function header to get scope of
        -- -- its body.
        -- try_as_border = false,
      },
      -- symbol = "│",
      symbol = "▏",
    })
    vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = "Comment" })

    -- local MiniStatusline = require("mini.statusline");

    -- MiniStatusline.setup({
    --   content = {
    --     active = function()
    --       local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
    --       local git           = MiniStatusline.section_git({ trunc_width = 75 })
    --       local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
    --       local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
    --       local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
    --       local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
    --       local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
    --       local location      = MiniStatusline.section_location({ trunc_width = 75 })
    --       local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })
    --
    --       return MiniStatusline.combine_groups({
    --         { hl = mode_hl,                  strings = { mode } },
    --         { hl = "MiniStatuslineDevinfo",  strings = { git, diff, diagnostics, lsp } },
    --         "%<", -- truncate point
    --         { hl = "MiniStatuslineFilename", strings = { filename } },
    --         "%=", -- right-align
    --         { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
    --         { hl = mode_hl,                  strings = { search, location } },
    --       })
    --     end,
    --   },
    --   use_icons = true,
    -- })
    --
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
