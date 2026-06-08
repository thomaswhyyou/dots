-- https://github.com/stevearc/oil.nvim
return {
  "stevearc/oil.nvim",
  lazy = false, -- Lazy loading is not recommended.
  -- dependencies = {
  --   { "nvim-mini/mini.nvim", opts = {} },
  -- },
  dependencies = {
    { "nvim-mini/mini.icons", opts = {} },
  },
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      watch_for_changes = true,
      view_options = {
        show_hidden = true,
      },
      use_default_keymaps = false,
      keymaps = {
        -- Defaults:
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        -- Custom:
        ["q"] = { "actions.close", mode = "n" },
        ["yy"] = {
          -- https://www.reddit.com/r/neovim/comments/1czp9zr/how_to_copy_file_path_to_clipboard_in_oilnvim/
          desc = "Copy filepath to system clipboard",
          callback = function()
            require("oil.actions").copy_entry_path.callback()
            vim.fn.setreg("+", vim.fn.getreg(vim.v.register))
          end,
        },
      },
    })

    -- Mimic the vim-vinegar method of navigating to the parent dir of a file.
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent dir" })

    -- Show hidden files/dirs in the same color as regular ones.
    vim.api.nvim_set_hl(0, "OilFileHidden", { link = "OilFile" })
    vim.api.nvim_set_hl(0, "OilDirHidden", { link = "OilDir" })

    -- Add a couple special behaviors inside the oil buffer.
    vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufEnter" }, {
      pattern = "*",
      callback = function(event)
        if vim.api.nvim_buf_get_name(event.buf):match(".*://") then
          -- Don't highlight words like todo, hack, etc in oil.
          vim.b.minihipatterns_disable = true
          -- Don't allow shortcuts to cycle through buffers while in oil.
          vim.keymap.set("n", "<Tab>", "<nop>", { buffer = true })
          vim.keymap.set("n", "<S-Tab>", "<nop>", { buffer = true })
          -- Use static line numbers inside oil buffers.
          vim.opt_local.relativenumber = false
        end
      end,
    })

    -- XXX: OilDir
    -- https://github.com/loctvl842/monokai-pro.nvim/issues/137
    -- OilDir = {
    --   bg = c.editor.background,
    -- }
  end,
}
