return {
  "https://github.com/neovim/nvim-lspconfig",
  config = function()
    -- TODO: Migrate once nvim-lspconfig supports TS v7+
    vim.lsp.config("tsgo", {
      cmd = { "tsc", "--lsp", "--stdio" },
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      root_dir = vim.fs.root(0, { "package.json", "tsconfig.json", ".git" }),
    })

    vim.lsp.enable({
      "lua_ls",
      "rust_analyzer",
      "dexter",
      "tsgo",
    })
  end,
}
