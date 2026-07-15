return {
  "https://github.com/rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  config = function()
    require("tiny-inline-diagnostic").setup({
      preset = "powerline",
    })
    -- Disable Neovim's default virtual text diagnostics
    -- References: https://neovim.io/doc/user/diagnostic/
    vim.diagnostic.config({ virtual_text = false })
  end,
}
