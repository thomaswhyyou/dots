return {
  "https://github.com/akinsho/toggleterm.nvim",
  enabled = false, -- Using snacks terminal instead
  version = "*",
  config = function()
    require("toggleterm").setup({
      start_in_insert = true, -- default; ensures new terms open in insert
      persist_mode = false, -- always re-open in insert, ignore last mode
      size = function(term)
        if term.direction == "horizontal" then
          return 40
        else
          return 100
        end
      end,
    })

    -- Toggle terminal
    local function toggle()
      local dir = vim.o.columns >= 250 and "vertical" or "horizontal"
      vim.cmd("ToggleTerm direction=" .. dir)
    end
    -- Ctrl+/ arrives as <C-/> in modern terminals (CSI-u/Kitty protocol) but as
    -- <C-_> (0x1F) in legacy ones, so bind both to cover either encoding.
    vim.keymap.set({ "n", "t" }, "<C-/>", toggle, { noremap = true, silent = true })
    vim.keymap.set({ "n", "t" }, "<C-_>", toggle, { noremap = true, silent = true })

    -- Exit terminal mode in terminal
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*toggleterm#*",
      callback = function(ev)
        vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = ev.buf })
      end,
    })

    local Terminal = require("toggleterm.terminal").Terminal

    -- Lazygit
    local lazygit = Terminal:new({
      cmd = "lazygit",
      dir = "git_dir",
      direction = "float",
      display_name = "lazygit",
      hidden = true,
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = term.bufnr, silent = true })
      end,
    })
    vim.keymap.set("n", "<leader>gg", function()
      if vim.fn.executable("lazygit") == 0 then
        vim.notify("lazygit is not installed", vim.log.levels.WARN)
        return
      end
      lazygit:toggle()
    end, { desc = "Lazygit" })
  end,
}
