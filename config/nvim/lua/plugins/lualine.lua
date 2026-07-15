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
        always_show_tabline = false,
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
            color = { fg = directory_fg, gui = "bold" },
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
            symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
          },
          {
            "lsp_status",
            icon = "",
            color = { fg = directory_fg, gui = "bold" },
          },
        },
        lualine_y = {
          -- Current line:column total lines, e.g. 120:8 350
          { "%l:%-2v %L", color = normal_b },
        },
        lualine_z = { "searchcount" },
      },
      tabline = {
        lualine_z = {
          {
            "tabs",
            section_separators = { left = "", right = "" },
          },
        },
      },
    })
  end,
}
