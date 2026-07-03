return {
  "https://github.com/dstein64/nvim-scrollview",
  config = function()
    require("scrollview").setup({
      current_only = true,
      excluded_filetypes = { "blame" },
    })
  end,
}
