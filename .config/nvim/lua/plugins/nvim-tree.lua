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
      -- view = {
      --   float = {
      --     enable = true,
      --     open_win_config = function()
      --       local cols = vim.opt.columns:get()
      --       local lines = vim.opt.lines:get()
      --       local width = math.floor(cols * 0.4)
      --       local height = math.floor(lines * 0.8)
      --       return {
      --         relative = "editor",
      --         border = "rounded",
      --         width = width,
      --         height = height,
      --         row = math.floor((lines - height) / 2),
      --         col = math.floor((cols - width) / 2),
      --       }
      --     end,
      --   },
      --   width = function()
      --     return math.floor(vim.opt.columns:get() * 0.4)
      --   end,
      -- },
      -- -- update_focused_file = {
      -- --   enable = true,
      -- --   update_root = false,
      -- -- },
      -- actions = {
      --   open_file = {
      --     quit_on_open = true, -- close the float after opening a file
      --   },
      -- },
    })
    -- Toggle: if open, close; if closed, open and reveal current buffer
    vim.keymap.set("n", "<leader>e", function()
      local api = require("nvim-tree.api")
      if api.tree.is_visible() then
        api.tree.close()
      else
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname ~= "" and vim.fn.filereadable(bufname) == 1 then
          api.tree.find_file({ open = true, focus = true })
        else
          api.tree.open()
        end
      end
    end, { desc = "Toggle nvim-tree (reveal current file)" })
  end,
}
