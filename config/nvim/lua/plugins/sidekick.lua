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
          },
        },
      },
    })

    local cli = require("sidekick.cli")

    -- Herdr integration: when running inside a Herdr session, register the
    -- Herdr session backend so `cli.send` can route to a Herdr pane running an
    -- AI agent. No-op (and untouched behaviour) outside Herdr.
    local in_herdr = vim.env.HERDR_ENV == "1"
    local herdr = in_herdr and require("lib.sidekick_herdr").setup() or nil

    -- Open a new narrow Herdr pane to the right running Claude and bind to it.
    -- Bound is a noop (the pane already exists) so repeat presses are harmless.
    if in_herdr and herdr then
      vim.keymap.set("n", "<leader>aoc", function()
        if herdr.is_bound() then
          vim.notify(
            "Herdr: already bound to an agent pane",
            vim.log.levels.INFO,
            { title = "Sidekick" }
          )
          return
        end
        herdr.spawn_agent({ tool = "claude" })
      end, { desc = "Herdr New Claude Pane" })

      vim.keymap.set("n", "<leader>ab", function()
        herdr.bind_pick()
      end, { desc = "Herdr Bind Agent Pane" })

      vim.keymap.set("n", "<leader>au", function()
        herdr.unbind()
      end, { desc = "Herdr Unbind Agent Pane" })
    else
      vim.keymap.set("n", "<leader>aa", function()
        cli.toggle({ filter = { installed = true, focus = true } })
      end, { desc = "Sidekick Select" })
    end

    -- Routing filter for context sends, recomputed per keypress (bind/agent
    -- state changes at runtime):
    --   * bound, or lone agent in Neovim's Herdr tab  -> exact pane, no picker
    --   * other Herdr agents                          -> auto-pick if one, else prompt
    --   * outside Herdr / none yet                    -> any installed tool (terminal)
    local function target()
      return (herdr and herdr.target_filter()) or { installed = true }
    end

    vim.keymap.set({ "n", "x" }, "<leader>at", function()
      cli.send({ msg = "{this}", filter = target() })
    end, { desc = "Send This" })

    vim.keymap.set("n", "<leader>af", function()
      cli.send({ msg = "{file}", filter = target() })
    end, { desc = "Send File" })

    vim.keymap.set("x", "<leader>av", function()
      cli.send({ msg = "{selection}", filter = target() })
    end, { desc = "Send Visual Selection" })

    vim.keymap.set({ "n", "x" }, "<leader>ap", function()
      cli.prompt()
    end, { desc = "Sidekick Select Prompt" })
  end,
}
