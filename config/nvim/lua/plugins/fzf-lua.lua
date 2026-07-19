return {
  "https://github.com/ibhagwan/fzf-lua",
  config = function()
    local fzf = require("fzf-lua")
    local height = 0.85
    local width = math.max(math.floor(vim.o.columns * 0.4), 120)

    fzf.setup({
      -- Rebind multi-select from tab/shift-tab to ctrl-space
      keymap = {
        fzf = {
          ["ctrl-space"] = "toggle", -- toggle selection without moving
          ["tab"] = "down", -- tab now just moves down
          ["shift-tab"] = "up", -- shift-tab now just moves up
        },
      },
      winopts = {
        width = width,
        preview = {
          hidden = true,
          horizontal = "right:50%",
        },
        backdrop = 100, -- No backdrop opacity (so no flicker between tab switches).
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
        cwd_prompt = false,
        -- stylua: ignore
        actions = {
          ["tab"] = function(_, _) fzf.buffers() end,
          ["shift-tab"] = function(_, _) fzf.builtin() end,
        },
      },
      buffers = {
        cwd_prompt = false,
        -- stylua: ignore
        actions = {
          ["tab"] = function(_, _) fzf.tagstack() end,
          ["shift-tab"] = function(_, _) fzf.builtin() end,
        },
      },
      tagstack = {
        -- stylua: ignore
        actions = {
          ["tab"] = function(_, _) fzf.files() end,
          ["shift-tab"] = function(_, _) fzf.builtin() end,
          -- Clear the current window's tag stack (picker closes after)
          ["ctrl-d"] = function(_, _)
            vim.fn.settagstack(vim.api.nvim_get_current_win(), { items = {} }, "r")
          end,
        },
      },
      builtin = {
        -- builtin has its own default winopts (0.65x0.65) that override the
        -- global ones, so re-apply the shared size here
        winopts = { height = height, width = width },
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

    vim.keymap.set("n", "<leader>p", function() fzf.files() end, { desc = "Fzf Files" })
    vim.keymap.set("n", "<leader>/", function() fzf.grep() end, { desc = "Fzf Grep" })

    -- Fzf-flavored versions of the default LSP keymaps
    -- (grn stays default since rename is an input prompt, not a list).
    -- LSP pickers open with a visible preview
    local lsp_opts = {
      winopts = {
        width = math.max(math.floor(vim.o.columns * 0.65), 140),
        preview = { hidden = false },
      },
    }
    vim.keymap.set("n", "gO", function() fzf.lsp_document_symbols(lsp_opts) end, { desc = "Fzf Document Symbols" })
    vim.keymap.set({ "n", "x" }, "gra", function() fzf.lsp_code_actions(lsp_opts) end, { desc = "Fzf Code Actions" })
    vim.keymap.set("n", "grr", function() fzf.lsp_references(lsp_opts) end, { desc = "Fzf References" })
    vim.keymap.set("n", "gri", function() fzf.lsp_implementations(lsp_opts) end, { desc = "Fzf Implementations" })
  end,
}
