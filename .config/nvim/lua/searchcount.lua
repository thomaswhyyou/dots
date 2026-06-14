-- Virtual-text search count, replicating noice.nvim's `[i/N]` badge.
--
-- Noice routes Neovim's `search_count` message to a "virtualtext" view that
-- draws an extmark at end-of-line using `DiagnosticVirtualTextInfo` (blue-ish).
-- This module is standalone: it wraps `vim.fn.searchcount()` directly (see
-- `searchcount_str`) and owns *placement* (the extmark) and *triggers* (the
-- autocmds).

local M = {}

local ns = vim.api.nvim_create_namespace("user_search_count")

local displayed = false -- whether a badge is currently drawn (for the on_key guard)

-- Format `vim.fn.searchcount()` as `current/total`, gated on `v:hlsearch`.
-- Mirrors `mini.statusline.section_searchcount`: searchcount() is wrapped in
-- pcall because while typing a pattern it can raise (e.g. `/\(` gives E54), and
-- `>maxcount` / `?/?` (incomplete) are formatted the way noice's badge shows.
local function searchcount_str(options)
  if vim.v.hlsearch == 0 then return "" end

  local ok, s = pcall(vim.fn.searchcount, options)
  if not ok or s.current == nil or s.total == 0 then return "" end

  if s.incomplete == 1 then return "?/?" end

  local too_many = (">%d"):format(s.maxcount)
  local current = s.current > s.maxcount and too_many or s.current
  local total = s.total > s.maxcount and too_many or s.total
  return ("%s/%s"):format(current, total)
end

function M.clear()
  displayed = false
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

-- True if the cursor sits at the start of a match for `pattern`. `searchpos`
-- with `cnW` returns the match at-or-after the cursor without moving (`c`
-- accepts a match beginning at the cursor, `n` no-move, `W` no-wrap); when that
-- start equals the cursor we're on a hit. Search jumps / n / N / * / # all land
-- on a match's start, so the badge shows there but is dropped once h/j/k/l move
-- off it. pcall guards bad patterns (e.g. E54), as in `searchcount_str`.
local function cursor_on_match(pattern)
  if pattern == "" then return false end
  local cursor = vim.api.nvim_win_get_cursor(0) -- { row (1-based), col (0-based) }
  local ok, pos = pcall(vim.fn.searchpos, pattern, "cnW") -- { row (1-based), col (1-based) }
  if not ok then return false end
  return pos[1] == cursor[1] and pos[2] == cursor[2] + 1
end

-- Draw the `[current/total]` badge at the end of the cursor line.
-- `pattern` (live incsearch) is forwarded to searchcount; otherwise the count is
-- against the last search register and is "" unless `v:hlsearch` is on.
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
    -- Only show against the cursor line when the cursor is actually on a match;
    -- otherwise moving with h/j/k/l would drag a stale badge along the buffer.
    if not cursor_on_match(term) then return end
  end

  local str = searchcount_str(options)
  if str == "" then return end

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
