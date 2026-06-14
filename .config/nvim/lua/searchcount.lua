-- Virtual-text search count, replicating noice.nvim's `[i/N]` badge.
--
-- Noice routes Neovim's `search_count` message to a "virtualtext" view that
-- draws an extmark at end-of-line using `DiagnosticVirtualTextInfo` (blue-ish).
-- We don't reimplement the count: `mini.statusline.section_searchcount()` (mini
-- is already installed) wraps `vim.fn.searchcount()` and handles the `v:hlsearch`
-- gate, invalid-pattern errors (E54), and `?/?` / `>maxcount` formatting. This
-- module only owns *placement* (the extmark) and *triggers* (the autocmds).

local M = {}

local ns = vim.api.nvim_create_namespace("user_search_count")

local displayed = false -- whether a badge is currently drawn (for the on_key guard)

function M.clear()
  displayed = false
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

-- Draw the `[current/total]` badge at the end of the cursor line.
-- `pattern` (live incsearch) is forwarded to searchcount; otherwise mini counts
-- against the last search register and returns "" unless `v:hlsearch` is on.
local function render(pattern)
  M.clear()

  local options = { recompute = true, maxcount = 999 }
  local term
  if pattern ~= nil then
    if pattern == "" then return end
    options.pattern = pattern
    term = pattern
  else
    term = vim.fn.getreg("/")
  end

  -- No `trunc_width` so the badge never truncates by window width.
  local ok, str = pcall(function()
    return require("mini.statusline").section_searchcount({ options = options })
  end)
  if not ok or str == nil or str == "" then return end

  -- e.g. `foo [1/3]`, search term to the left of the count, like noice.
  local label = ("%s [%s]"):format(term, str)

  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  vim.api.nvim_buf_set_extmark(0, ns, row, 0, {
    -- Leading gap is a separate unhighlighted chunk so `SearchCount` (which may
    -- have a background) only colors the readable text.
    virt_text = { { "    " }, { label, "SearchCount" } },
    virt_text_pos = "eol",
    hl_mode = "combine",
  })
  displayed = true
end

function M.setup()
  -- Blue-ish "info" text, matching noice's default. `default = true` keeps it
  -- overridable, and the link resolves lazily once the colorscheme loads.
  vim.api.nvim_set_hl(0, "SearchCount", { default = true, link = "DiagnosticVirtualTextInfo" })

  local group = vim.api.nvim_create_augroup("user_search_count", { clear = true })

  -- `:noh` / `clearmatches()` fire no autocmd and there's no event for
  -- `v:hlsearch` turning off, so watch keystrokes: after any key is processed
  -- while a badge is up, drop it if the search highlight is now gone. Guarded by
  -- `displayed` so it's a no-op the rest of the time.
  vim.on_key(function()
    if not displayed then return end
    vim.schedule(function()
      if vim.v.hlsearch == 0 then M.clear() end
    end)
  end, ns)

  -- Covers the jump after `/foo<CR>`, and n / N / * / #.
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    callback = function() render() end,
  })

  -- Live count while typing a `/` or `?` search.
  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = group,
    callback = function()
      local t = vim.fn.getcmdtype()
      if t == "/" or t == "?" then
        render(vim.fn.getcmdline())
      end
    end,
  })

  -- After confirming/cancelling the search, re-render from the real state.
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = function()
      local t = vim.fn.getcmdtype()
      if t == "/" or t == "?" then
        vim.schedule(function() render() end)
      end
    end,
  })
end

return M
