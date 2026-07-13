return {
  "https://github.com/Bekaboo/dropbar.nvim",
  config = function()
    local dropbar = require("dropbar")
    local sources = require("dropbar.sources")

    dropbar.setup({
      icons = {
        kinds = {
          dir_icon = "",
        },
      },
      bar = {
        sources = function(buf, _)
          if vim.bo[buf].buftype == "terminal" then
            return { sources.terminal }
          end
          return { sources.path }
        end,
      },
    })

    local api = require("dropbar.api")
    vim.keymap.set("n", "<Leader>;", api.pick, { desc = "Pick symbols in winbar" })
  end,
}
