return {
  -- https://github.com/rachartier/tiny-inline-diagnostic.nvim
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({
        preset = "powerline",
      })
      vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
    end,
  },

  -- https://github.com/nvim-lualine/lualine.nvim
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    enabled = false,
    config = function()
      -- require("lualine").setup({
      --   options = { theme = "monokai-v2" },
      -- })

      -- Eviline config for lualine
      -- Author: shadmansaleh
      -- Credit: glepnir
      local lualine = require("lualine")

      -- Color table for highlights
      -- stylua: ignore
      local colors = {
        bg       = "#202328",
        fg       = "#bbc2cf",
        yellow   = "#ECBE7B",
        cyan     = "#008080",
        darkblue = "#081633",
        green    = "#98be65",
        orange   = "#FF8800",
        violet   = "#a9a1e1",
        magenta  = "#c678dd",
        blue     = "#51afef",
        red      = "#ec5f67",
      }

      colors.white = "#ffffff"
      colors.black = "#000000"

      -- https://github.com/NTBBloodbath/doom-one.nvim/blob/main/lua/doom-one/colors.lua
      -- local colors = {}
      --
      -- colors.default = {
      --   bg = "#202328",
      --   fg = "#bbc2cf",
      --   yellow = "#ECBE7B",
      --   cyan = "#008080",
      --   darkblue = "#081633",
      --   green = "#98be65",
      --   orange = "#FF8800",
      --   violet = "#a9a1e1",
      --   magenta = "#c678dd",
      --   blue = "#51afef",
      --   red = "#ec5f67",
      -- }

      -- dracula
      -- local colors = {
      --   bg = "#21222C",
      --   fg = "#F8F8F2",
      --   fg_alt = "#ABB2BF",
      --   yellow = "#F1FA8C",
      --   cyan = "#8BE9FD",
      --   green = "#50FA7B",
      --   orange = "#FFB86C",
      --   magenta = "#BD93F9",
      --   blue = "#A4FFFF",
      --   red = "#FF5555",
      --   violet = "#a9a1e1",
      -- }

      -- Config
      local config = {
        options = {
          -- Disable sections and component separators
          component_separators = "",
          section_separators = "",
          -- theme = "monokai-v2"
          -- theme = "monokai-pro"
          -- theme = "auto"
          -- theme = {
          --   -- We are going to use lualine_c an lualine_x as left and
          --   -- right section. Both are highlighted by c theme .  So we
          --   -- are just setting default looks o statusline
          --   normal = { c = { fg = colors.fg, bg = colors.bg } },
          --   inactive = { c = { fg = colors.fg, bg = colors.bg } },
          -- },
        },
        sections = {
          -- Remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        inactive_sections = {
          -- Remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
      }

      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
          local filepath = vim.fn.expand("%:p:h")
          local gitdir = vim.fn.finddir(".git", filepath .. ";")
          return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
      }

      -- Inserts a component in lualine_c at left section
      local function ins_left(component)
        table.insert(config.sections.lualine_c, component)
      end

      -- Inserts a component in lualine_x at right section
      local function ins_right(component)
        table.insert(config.sections.lualine_x, component)
      end

      -- Mode component
      -- https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#crash-course-the-vimode
      ins_left({
        function()
          local mode_names = {
            n = "NORMAL",
            no = "N·OP",
            nov = "N·OP",
            noV = "N·OP",
            ["no\22"] = "N·OP",
            niI = "NORMAL",
            niR = "NORMAL",
            niV = "NORMAL",
            nt = "NORMAL",
            v = "VISUAL",
            vs = "VISUAL",
            V = "V-LINE",
            Vs = "V-LINE",
            ["\22"] = "V-BLCK",
            ["\22s"] = "V-BLCK",
            s = "SELECT",
            S = "S-LINE",
            ["\19"] = "S-BLCK",
            i = "INSERT",
            ic = "INSERT",
            ix = "INSERT",
            R = "REPLACE",
            Rc = "REPLACE",
            Rx = "REPLACE",
            Rv = "V-RPLCE",
            Rvc = "V-RPLCE",
            Rvx = "V-RPLCE",
            c = "COMMAND",
            cv = "COMMAND",
            r = "PROMPT",
            rm = "MORE",
            ["r?"] = "CONFIRM",
            ["!"] = "SHELL",
            t = "TERM",
          }
          -- return " %2(" .. mode_names[vim.fn.mode()] .. "%)"
          return mode_names[vim.fn.mode()]
        end,
        color = function()
          local mode_color = {
            n = colors.red,
            i = colors.green,
            v = colors.blue,
            [""] = colors.blue,
            V = colors.blue,
            c = colors.magenta,
            no = colors.red,
            s = colors.orange,
            S = colors.orange,
            [""] = colors.orange,
            ic = colors.yellow,
            R = colors.violet,
            Rv = colors.violet,
            cv = colors.red,
            ce = colors.red,
            r = colors.cyan,
            rm = colors.cyan,
            ["r?"] = colors.cyan,
            ["!"] = colors.red,
            t = colors.white,
          }
          return {
            bg = mode_color[vim.fn.mode()],
            fg = colors.bg,
            gui = "bold",
          }
        end,
        padding = { left = 1, right = 1 },
      })

      -- ins_left({
      --   function()
      --     local filename = vim.api.nvim_buf_get_name(0)
      --
      --     self.lfilename = vim.fn.fnamemodify(filename, ":.")
      --     if self.lfilename == "" then
      --       self.lfilename = "[No Name]"
      --     end
      --     if not conditions.width_percent_below(#self.lfilename, 0.27) then
      --       self.lfilename = vim.fn.pathshorten(self.lfilename)
      --     end
      --   end,
      --   cond = conditions.buffer_not_empty,
      --   color = { fg = colors.blue, gui = "bold" },
      -- })

      -- TODO: https://github.com/bwpge/lualine-pretty-path/
      ins_left({
        "filename",
        path = 1,
        shorting_target = 100,
        cond = conditions.buffer_not_empty,
        color = {
          fg = colors.magenta,
          -- gui = "bold"
        },
      })

      ins_left({
        "branch",
        icon = "",
        color = { fg = colors.yellow, gui = "bold" },
      })

      ins_left({
        "diff",
        -- Is it me or the symbol for modified us really weird
        symbols = { added = " ", modified = "󰝤 ", removed = " " },
        diff_color = {
          added = { fg = colors.green },
          modified = { fg = colors.orange },
          removed = { fg = colors.red },
        },
        cond = conditions.hide_in_width,
      })

      ins_left({
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " " },
        diagnostics_color = {
          error = { fg = colors.red },
          warn = { fg = colors.yellow },
          info = { fg = colors.cyan },
        },
      })

      -- Insert mid section. You can make any number of sections in neovim :)
      -- for lualine it's any number greater then 2
      ins_left({
        function()
          return "%="
        end,
      })

      ins_left({
        -- Lsp server name .
        function()
          local msg = "n/a"
          local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
          local clients = vim.lsp.get_clients()
          if next(clients) == nil then
            return msg
          end
          for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
              return client.name
            end
          end
          return msg
        end,
        icon = "LSP:",
        -- color = { fg = "#ffffff", gui = "bold" },
        color = { fg = "#ffffff" },
      })

      ins_right({
        -- %l = current line number
        -- %L = number of lines in the buffer
        -- %c = column number
        -- %P = percentage through file of displayed window
        -- "%7(%l/%3L%):%2c %P",
        -- "%l:%c %P/%L",
        "%l:%c/%L %P",
        color = { fg = colors.white },
      })

      -- Now don't forget to initialize lualine
      lualine.setup(config)
    end,
  },
}
