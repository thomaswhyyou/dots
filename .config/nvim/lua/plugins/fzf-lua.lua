return {
  "https://github.com/ibhagwan/fzf-lua",
  -- stylua: ignore
  keys = {
    { "<leader>p", function() require("fzf-lua").files() end, desc = "Fzf Files" },
    { "<leader>/", function() require("fzf-lua").grep() end, desc = "Fzf Grep" },
  },
  config = function()
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

      -- TODO: Clean up the configs
      -- https://github.com/gennaro-tedesco/dotfiles/blob/master/nvim/lua/plugins/fzf.lua
      files = {
        -- formatter = "path.filename_first",
        -- git_icons = false,
        -- no_header = true,
        -- cwd_header = false,
        cwd_prompt = false,
        -- cwd = require("utils").git_root(),
        actions = {
          ["tab"] = function(_, _)
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

-- search
-- { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
-- { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
-- { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
-- { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
-- { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
-- { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
-- { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
-- { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
-- { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
-- { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
-- { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
-- { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
-- { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
-- { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
-- { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
-- { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
-- { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
-- { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
-- LSP
-- { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
-- { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
-- { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
-- { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
-- { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
-- { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
-- { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
