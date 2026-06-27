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
