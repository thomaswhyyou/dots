return {
  "https://github.com/Bekaboo/dropbar.nvim",
  enabled = false,
  config = function()
    -- Capture before setup() to avoid infinite recursion, setup() merges
    -- overrides into this same table.
    local default_enable = require("dropbar.configs").opts.bar.enable

    require("dropbar").setup({
      icons = {
        kinds = { dir_icon = "" },
      },
      sources = {
        lsp = { max_depth = 1 },
        treesitter = { max_depth = 1 },
      },
      bar = {
        enable = function(buf, win, info)
          if vim.bo[buf].buftype == "terminal" then
            return false
          end
          return default_enable(buf, win, info)
        end,
      },
    })

    local api = require("dropbar.api")
    vim.keymap.set("n", "<Leader>;", api.pick, { desc = "Pick symbols in winbar" })
  end,
}
