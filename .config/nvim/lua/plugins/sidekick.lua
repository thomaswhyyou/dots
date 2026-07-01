return {
  "https://github.com/folke/sidekick.nvim",
  opts = {
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
  },
  keys = {
    {
      "<c-.>",
      function() require("sidekick.cli").toggle({ filter = { installed = true } }) end,
      desc = "Sidekick Toggle",
    },
    {
      "<leader>as",
      function()
        require("sidekick.cli").select({ filter = { installed = true } })
      end,
      desc = "Sidekick Select",
    },
    -- {
    --   "<leader>aa",
    --   function() require("sidekick.cli").toggle({ filter = { installed = true } }) end,
    --   desc = "Sidekick Toggle CLI",
    -- },
    -- { "<leader>ad", function() require("sidekick.cli").close() end, desc = "Detach a CLI Session" },
    { "<leader>at", function() require("sidekick.cli").send({ msg = "{this}" }) end, mode = { "x", "n" }, desc = "Send This" },
    { "<leader>af", function() require("sidekick.cli").send({ msg = "{file}" }) end, desc = "Send File" },
    { "<leader>av", function() require("sidekick.cli").send({ msg = "{selection}" }) end, mode = { "x" }, desc = "Send Visual Selection" },
    { "<leader>ap", function() require("sidekick.cli").prompt() end, mode = { "n", "x" }, desc = "Sidekick Select Prompt" },

    -- Example of a keybinding to open Claude directly
    {
      "<leader>ac",
      function()
        require("sidekick.cli").toggle({ name = "claude", focus = true })
      end,
      desc = "Sidekick Toggle Claude",
    },
  },
}
