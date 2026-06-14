-- https://github.com/folke/noice.nvim
return {
  "folke/noice.nvim",
  enabled = false,
  dependencies = { "MunifTanjim/nui.nvim" },
  event = "VeryLazy",
  opts = {
    cmdline = {
      enabled = false,
      view = "cmdline_popup",
    },
    views = {
      cmdline_popup = {
        position = { row = "94%", col = "50%" },
        size = { width = 80, height = "auto" },
      },
    },
    messages = { enabled = false },
    popupmenu = { enabled = false },
    notify = { enabled = false },
    lsp = {
      progress = { enabled = false },
      hover = { enabled = false },
      signature = { enabled = false },
      message = { enabled = false },
    },
  },
}
