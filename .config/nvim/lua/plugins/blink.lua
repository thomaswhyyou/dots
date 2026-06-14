-- TODO: Maybe remove blink
-- https://justinhj.github.io/2026/04/06/refreshing-your-neovim-config-for-0-12-0.html
-- https://blog.viktomas.com/graph/neovim-native-built-in-lsp-autocomplete/

-- Native completion
vim.opt.completeopt = "menu,menuone,noselect,popup" -- Ensures the menu appears even for a single match and uses the native popup window.
vim.o.autocomplete = true -- Enables the overall completion feature.

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_completion", { clear = true }),
  callback = function(args)
    local client_id = args.data.client_id
    if not client_id then
      return
    end

    local client = vim.lsp.get_client_by_id(client_id)
    if client and client:supports_method("textDocument/completion") then
      -- Enable native LSP completion for this client + buffer
      vim.lsp.completion.enable(true, client_id, args.buf, {
        autotrigger = true,   -- auto-show menu as you type (recommended)
        -- You can also set { autotrigger = false } and trigger manually with <C-x><C-o>
      })
    end
  end,
})

-- https://github.com/saghen/blink.cmp
return {
  "saghen/blink.cmp",
  enabled = false,
  dependencies = { "rafamadriz/friendly-snippets" },
  version = "1.*",
  opts = {
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = "super-tab",
      ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
      ["<C-j>"] = { "select_next", "fallback_to_mappings" },
    },
    completion = {
      list = { selection = { preselect = false, auto_insert = true } },
    },
    cmdline = {
      keymap = {
        preset = "inherit",
        -- recommended, as the default keymap will only show and select the next item
        ["<Tab>"] = { "show", "accept" },
      },
    },
  },
}
