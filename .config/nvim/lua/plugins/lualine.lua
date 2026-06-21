-- https://github.com/nvim-lualine/lualine.nvim
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    local theme = require("lualine.themes.auto")
    -- Constant plain text/background color (don't follow the per-mode theme).
    local normal_b = { fg = theme.normal.c.fg, bg = theme.normal.b.bg }

    require("lualine").setup({
      options = {
        -- No separators between components within a section.
        component_separators = "",
        -- Diagonal slant between sections
        section_separators = {
          left = vim.fn.nr2char(0xE0B8), -- nf-ple-lower_left_triangle (\)
          right = vim.fn.nr2char(0xE0BA), -- nf-ple-lower_right_triangle (/)
        },
        -- Single statusline for the whole editor (laststatus = 3).
        globalstatus = true,
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
              -- Truncate long branch names: first 16 + … + last 4.
              if #name <= 20 then
                return name
              end
              return name:sub(1, 16) .. "…" .. name:sub(-4)
            end,
          },
        },
        lualine_c = {
          { "filetype", icon_only = true, padding = { left = 1, right = 0 } },
          { "filename", path = 1, padding = { left = 0, right = 1 } },
          { "diff" },
        },
        -- Right hand side
        lualine_x = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
          },
          { "lsp_status", icon = "" },
        },
        lualine_y = {
          -- Current line:column total lines, e.g. 120:8 350
          { "%l:%-2v %L", color = normal_b },
        },
        lualine_z = { "searchcount" },
      },
    })
  end,
}
