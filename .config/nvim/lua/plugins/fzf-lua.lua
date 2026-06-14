-- https://github.com/ibhagwan/fzf-lua
-- TODO: Clean up the configs
return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-mini/mini.icons" },
  -- stylua: ignore
  keys = {
    -- Shortcuts
    { "<leader>p", function() require("fzf-lua").files() end, desc = "Fzf files" },
    { "<leader>/", function() require("fzf-lua").grep() end, desc = "Fzf grep" },

    -- Search
    { "<leader>sg", function() require("fzf-lua").live_grep() end, desc = "Fzf live grep" },
  },
  -- opts = { },
  config = function()
    -- TODO: bind require("fzf-lua") to a local var

    require("fzf-lua").setup({
      winopts = {
        height = 0.90,
        width = vim.o.columns < 240 and 0.8 or 0.4,
        row = 0.5,
        preview = {
          hidden = true,
          horizontal = "right:50%",
        },
        -- No backdrop opacity (so no flicker between tab switches).
        backdrop = 100,
        -- Set buffer-local terminal-mode keymaps that shadow any global ones
        -- (e.g. smart-splits) to ensure C-h/j/k/l work normally while in the
        -- fzf picker window.
        on_create = function()
          for _, key in ipairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>", "<C-\\>" }) do
            vim.keymap.set("t", key, key, { buffer = true, nowait = true })
          end
        end,
      },
      -- Use the default fzf layout
      fzf_opts = { ["--layout"] = "default" },
      -- Needs this so theme colors can be respected
      fzf_colors = true,

      -- https://github.com/gennaro-tedesco/dotfiles/blob/master/nvim/lua/plugins/fzf.lua
      files = {
        -- formatter = "path.filename_first",
        -- git_icons = false,
        -- no_header = true,
        -- cwd_header = false,
        cwd_prompt = false,
        -- cwd = require("utils").git_root(),
        actions = {
          -- ["ctrl-d"] = {
          --   fn = function(...)
          --     require("fzf-lua").actions.file_vsplit(...)
          --     vim.cmd("windo diffthis")
          --     local switch = vim.api.nvim_replace_termcodes("<C-w>h", true, false, true)
          --     vim.api.nvim_feedkeys(switch, "t", false)
          --   end,
          --   desc = "diff-file",
          -- },

          ["tab"] = function(_, _)
            -- open buffers picker
            require("fzf-lua").buffers()
          end,
        },
      },
      buffers = {
        -- cwd_prompt = false,
        -- cwd = require("utils").git_root(),
        actions = {
          ["tab"] = function(_, _)
            -- open buffers picker
            require("fzf-lua").files()
          end,
        },
      },
      grep = {
        winopts = {
          fullscreen = true,
          preview = {
            hidden = false,
          },
        },
      },
    })
  end,
}
