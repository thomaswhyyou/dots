return {
  "https://github.com/ibhagwan/fzf-lua",
  -- stylua: ignore
  keys = {
    { "<leader>p", function() require("fzf-lua").files() end, desc = "Fzf Files" },
    { "<leader>/", function() require("fzf-lua").grep() end, desc = "Fzf Grep" },
    { "gO", function() require("fzf-lua").lsp_document_symbols() end, desc = "Fzf Document Symbols" },
  },
  config = function()
    require("fzf-lua").setup({
      -- Rebind multi-select from tab/shift-tab to ctrl-space
      keymap = {
        fzf = {
          ["ctrl-space"] = "toggle", -- toggle selection without moving
          ["tab"] = "down", -- tab now just moves down
          ["shift-tab"] = "up", -- shift-tab now just moves up
        },
      },
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
      fzf_colors = true, -- Needs this so theme colors can be respected
      files = {
        -- stylua: ignore
        actions = {
          ["tab"] = function(_, _) require("fzf-lua").buffers() end,
        },
      },
      buffers = {
        -- stylua: ignore
        actions = {
          ["tab"] = function(_, _) require("fzf-lua").files() end,
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
