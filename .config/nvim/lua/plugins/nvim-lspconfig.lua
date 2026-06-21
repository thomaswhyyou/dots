-- https://github.com/neovim/nvim-lspconfig
return {
  "neovim/nvim-lspconfig",
  config = function()
    vim.lsp.enable({
      "lua_ls",
      "rust_analyzer",
      "dexter",
      "tsgo",
    })
  end,
}
