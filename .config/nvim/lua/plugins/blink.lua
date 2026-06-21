-- https://github.com/saghen/blink.cmp
return {
  "saghen/blink.cmp",
  dependencies = { "rafamadriz/friendly-snippets" },
  version = "1.*",
  opts = {
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = "super-tab",
      ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
      ["<C-j>"] = { "select_next", "fallback_to_mappings" },
    },
    completion = {
      list = { selection = { preselect = false, auto_insert = true } },
    },
    cmdline = {
      keymap = {
        preset = "inherit",
        -- recommended, as the default keymap will only show and select the next item
        ["<Tab>"] = { "show", "accept" },
      },
    },
  },
}
