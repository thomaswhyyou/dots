return {
  "https://github.com/folke/sidekick.nvim",
  config = function()
    require("sidekick").setup({
      nes = {
        enabled = false,
      },
      cli = {
        tools = {
          claude = { cmd = { "claude", "--dangerously-skip-permissions" } },
        },
        win = {
          split = {
            width = 100,
            height = 0,
          },
        },
      },
    })

    local cli = require("sidekick.cli")

    vim.keymap.set("n", "<c-.>", function()
      cli.toggle({ filter = { installed = true } })
    end, { desc = "Sidekick Toggle" })

    vim.keymap.set("n", "<leader>as", function()
      cli.select({ filter = { installed = true } })
    end, { desc = "Sidekick Select" })

    vim.keymap.set({ "x", "n" }, "<leader>at", function()
      cli.send({ msg = "{this}", filter = { installed = true } })
    end, { desc = "Send This" })

    vim.keymap.set("n", "<leader>af", function()
      cli.send({ msg = "{file}", filter = { installed = true } })
    end, { desc = "Send File" })

    vim.keymap.set("x", "<leader>av", function()
      cli.send({ msg = "{selection}", filter = { installed = true } })
    end, { desc = "Send Visual Selection" })

    vim.keymap.set({ "n", "x" }, "<leader>ap", function()
      cli.prompt()
    end, { desc = "Sidekick Select Prompt" })

    -- Example of a keybinding to open Claude directly
    vim.keymap.set("n", "<leader>ac", function()
      require("sidekick.cli").toggle({ name = "claude", focus = true })
    end, { desc = "Sidekick Toggle Claude" })
  end,
}
