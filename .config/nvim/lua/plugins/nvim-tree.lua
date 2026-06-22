-- https://github.com/nvim-tree/nvim-tree.lua
return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      view = {
        width = 50,
      },
      renderer = {
        group_empty = true,
        highlight_git = "name",
      },
      update_focused_file = { enable = true },
      live_filter = {
        -- When filtering (the `f` key), hide folders that contain no match.
        always_show_folders = false,
      },
    })
    -- Toggle: if open, close; if closed, open and reveal current buffer
    vim.keymap.set("n", "<leader>e", function()
      local api = require("nvim-tree.api")
      if api.tree.is_visible() then
        return api.tree.close()
      end
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname == "" or vim.fn.filereadable(bufname) ~= 1 then
        return api.tree.open()
      end
      -- Reveal the file, collapse everything, then reveal again so only the
      -- directories on the path to the current file are expanded.
      api.tree.find_file({ buf = bufname, open = true, focus = true })
      api.tree.collapse_all()
      api.tree.find_file({ buf = bufname })
    end, { desc = "Toggle nvim-tree (reveal current file)" })
  end,
}
