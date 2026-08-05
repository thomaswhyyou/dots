return {
  "https://github.com/nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    local theme = require("lualine.themes.auto")
    -- Constant plain text/background color (don't follow the per-mode theme).
    local normal_b = { fg = theme.normal.c.fg, bg = theme.normal.b.bg }
    -- Foreground color of the Directory highlight (nil if unset).
    local directory_hl = vim.api.nvim_get_hl(0, { name = "Directory", link = false })
    local directory_fg = directory_hl.fg and string.format("#%06x", directory_hl.fg)

    require("lualine").setup({
      options = {
        component_separators = "", -- No separators between components within a section.
        section_separators = { -- Diagonal slant between sections
          left = vim.fn.nr2char(0xE0B8), -- nf-ple-lower_left_triangle (\)
          right = vim.fn.nr2char(0xE0BA), -- nf-ple-lower_right_triangle (/)
        },
        globalstatus = true, -- Single statusline for the whole editor (laststatus = 3).
      },
      sections = {
        -- Left hand side
        lualine_a = {
          {
            "mode",
            fmt = function(s)
              return s:sub(1, 1)
            end,
            color = { gui = "bold" },
          },
        },
        lualine_b = {
          {
            "branch",
            icon = vim.fn.nr2char(0xF418), -- nf-oct-git_branch
            color = normal_b,
            fmt = function(name)
              -- Truncate long branch names: first 48 + … + last 4.
              if #name <= 48 then
                return name
              end
              return name:sub(1, 44) .. "…" .. name:sub(-4)
            end,
          },
        },
        lualine_c = {
          {
            -- Current working directory name, prefixed onto the filename.
            function()
              return vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. "/"
            end,
            color = { fg = directory_fg },
            padding = { left = 1, right = 0 },
            cond = function()
              -- Only when the file is inside the cwd; otherwise filename
              -- already shows an absolute path.
              return vim.startswith(vim.api.nvim_buf_get_name(0), vim.fn.getcwd() .. "/")
            end,
          },
          { "filename", path = 1, padding = { left = 1, right = 1 } },
          { "diff" },
        },
        -- Right hand side
        lualine_x = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = "E", warn = "W", info = "I", hint = "H" },
          },
          {
            "lsp_status",
            icon = "",
            color = { fg = directory_fg },
          },
        },
        lualine_y = {
          -- Current line:column total lines, e.g. 120:8 350
          { "%l:%-2v %L", color = normal_b },
        },
        lualine_z = { "searchcount" },
      },
      tabline = {
        lualine_a = {
          {
            "buffers",
            section_separators = { left = "", right = "" },
            separator = { left = "", right = "" },

            show_filename_only = true, -- Shows shortened relative path when set to false.
            hide_filename_extension = false, -- Hide filename extension when set to true.
            show_modified_status = true, -- Shows indicator when the buffer is modified.

            mode = 2, -- 2: Shows buffer name + buffer index
            max_length = vim.o.columns * 3 / 4, -- Maximum width of buffers component,

            filetype_names = {
              oil = "[oil]",
              fzf = "[fzf]",
            }, -- Shows specific buffer name for that filetype ( { `filetype` = `buffer_name`, ... } )

            buffers_color = {
              active = theme.insert.b,
              inactive = "lualine_c_normal",
            },

            symbols = {
              modified = " [+]",
              alternate_file = "",
              directory = "",
            },
          },
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
          {
            "tabs",
            -- Only show the tab list once a second tab exists
            cond = function()
              return #vim.api.nvim_list_tabpages() > 1
            end,
            section_separators = { left = "", right = "" },
          },
        },
      },
    })

    -- Jump straight to a buffer by its tabline index with <A-N>.
    -- The bang makes out-of-range indices a no-op instead of an error.
    for i = 1, 9 do
      vim.keymap.set("n", "<A-" .. i .. ">", function()
        -- Same index -> bufnr map the LualineBuffersJump command reads.
        local bufnr = require("lualine.components.buffers").bufpos2nr[i]
        if not bufnr then
          return
        end
        -- Already on screen? Move to that window rather than replacing the
        -- buffer in the current one.
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_get_buf(win) == bufnr then
            vim.api.nvim_set_current_win(win)
            return
          end
        end
        vim.cmd("LualineBuffersJump! " .. i)
      end, { desc = "Go to buffer " .. i })
    end
  end,
}
