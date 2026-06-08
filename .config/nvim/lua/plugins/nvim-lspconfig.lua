-- https://github.com/neovim/nvim-lspconfig
return {
  "neovim/nvim-lspconfig",
  config = function()
    -- https://github.com/remoteoss/dexter
    vim.lsp.config("dexter", {
      cmd = { "dexter", "lsp" },
      root_markers = { ".dexter/dexter.db", ".dexter.db", ".git", "mix.exs" },
      filetypes = { "elixir", "eelixir", "heex" },
      init_options = {
        followDelegates = true, -- jump through defdelegate to the target function
        -- stdlibPath = "",      -- override Elixir stdlib path (auto-detected)
        -- debug = false,        -- verbose logging to stderr (view with :LspLog)
      },
    })

    vim.lsp.enable({
      "lua_ls",
      "rust_analyzer",
      -- "expert",
      "dexter",
      "tsgo",
    })

    -- vim.diagnostic.config({
    --   virtual_lines = false, -- Show only for current line
    --   virtual_text = { current_line = true }, -- Disable classic inline text
    --   signs = true,
    --   underline = true,
    -- })

    -- TODO: Check if we wnat to configure any of this..
    -- https://neovim.io/doc/user/diagnostic/

    -- vim.diagnostic.config({
    --   severity_sort = true,
    --   underline = false,
    --
    --   -- -- virtual_text = true
    --   virtual_text = {
    --     current_line = true,
    --   },
    --
    --   -- Use the default configuration
    --   -- virtual_lines = true
    --
    --   -- Alternatively, customize specific options
    --   -- virtual_lines = {
    --   --  -- Only show virtual line diagnostics for the current cursor line
    --   --   current_line = true,
    --   -- },
    -- })
  end,
}
