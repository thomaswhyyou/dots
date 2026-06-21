-- Search-count badge for incline.nvim's floating window.
--
-- Same idea as `searchcount.lua` (noice's `term [i/N]` badge in blue), but
-- instead of owning an extmark this module only *computes* the badge and asks
-- incline to re-render; incline owns *placement* (the corner float). The two are
-- independent experiments and can run side by side.
--
-- Wiring: `incline.lua` calls `require("searchcount_incline").render_badge()`
-- inside its `render` and gets back `{ text, group }` chunks (or nil). The
-- autocmds here call `require("incline").refresh()` so the float updates while
-- searching, since incline has no idea search state changed on its own.

local M = {}

local ns = vim.api.nvim_create_namespace("user_search_count_incline")

-- Live `/`/`?` state captured from the cmdline. We can't reliably read
-- `getcmdtype()` / `getcmdline()` from incline's (scheduled) render, so the
-- autocmds stash the in-progress pattern here for `render_badge` to read.
local state = {
  searching = false, -- inside a `/` or `?` cmdline right now
  pattern = "",      -- the in-progress pattern while `searching`
  shown = false,     -- did the last render draw a badge (for the on_key guard)
}

-- Format `vim.fn.searchcount()` as `current/total`, gated on `v:hlsearch`.
-- Copied from `searchcount.lua` so the badge text matches exactly: pcall guards
-- bad in-progress patterns (e.g. `/\(` -> E54), and `>maxcount` / incomplete
-- counts are rendered the way noice's badge shows them.
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

-- True if the cursor sits at the start of a match for `pattern`. Same as
-- `searchcount.lua`: keeps the badge from trailing along on h/j/k/l once the
-- cursor leaves a match (only relevant outside live search, against the `/`
-- register).
local function cursor_on_match(pattern)
  if pattern == "" then return false end
  local cursor = vim.api.nvim_win_get_cursor(0)
  local ok, pos = pcall(vim.fn.searchpos, pattern, "cnW")
  if not ok then return false end
  return pos[1] == cursor[1] and pos[2] == cursor[2] + 1
end

-- Compute the `term [i/N]` label for the current state, or nil if nothing
-- should show. Called from incline's `render` (focused window only).
local function label()
  local options = { recompute = true, maxcount = 999 }
  local term
  if state.searching then
    if state.pattern == "" then return nil end
    options.pattern = state.pattern
    term = state.pattern
  else
    term = vim.fn.getreg("/")
    -- Outside live search the count is against the last search register; only
    -- show it while the cursor is parked on a match (post-jump, n/N, * / #).
    if not cursor_on_match(term) then return nil end
  end

  local str = searchcount_str(options)
  if str == "" then return nil end

  return ("%s [%s]"):format(term, str)
end

-- Public: incline render chunks for the badge, or nil. Records `state.shown` so
-- the on_key guard knows whether a stale badge needs clearing after `:noh`.
function M.render_badge()
  local text = label()
  state.shown = text ~= nil
  if text == nil then return nil end
  -- Leading space keeps the badge off incline's other content; the colored
  -- chunk only covers the readable text.
  return { { " " }, { text, group = "SearchCountIncline" } }
end

function M.setup()
  -- Blue-ish "info" text, matching noice / `searchcount.lua`. `default = true`
  -- keeps it overridable and resolves the link lazily once the colorscheme
  -- loads.
  vim.api.nvim_set_hl(0, "SearchCountIncline", { default = true, link = "DiagnosticVirtualTextInfo" })

  local group = vim.api.nvim_create_augroup("user_search_count_incline", { clear = true })

  local function refresh()
    -- Wrapped so we don't error before incline is loaded.
    local ok, incline = pcall(require, "incline")
    if ok then incline.refresh() end
  end

  -- `:noh` / `clearmatches()` fire no autocmd and there's no event for
  -- `v:hlsearch` turning off, so watch keystrokes: once a badge is up, drop it
  -- (refresh -> render returns nil) when the highlight is gone. Guarded by
  -- `state.shown` so it's a no-op the rest of the time.
  vim.on_key(function()
    if not state.shown then return end
    vim.schedule(function()
      if vim.v.hlsearch == 0 then refresh() end
    end)
  end, ns)

  -- Re-render after the post-search jump, and on n / N / * / # movement.
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    callback = refresh,
  })

  -- Live count while typing a `/` or `?` search. Refresh synchronously here so
  -- the float updates on the same redraw incsearch triggers as you type.
  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = group,
    callback = function()
      local t = vim.fn.getcmdtype()
      if t == "/" or t == "?" then
        state.searching = true
        state.pattern = vim.fn.getcmdline()
        refresh()
      end
    end,
  })

  -- Leaving the cmdline: clear the live pattern and re-render from the real
  -- search state (register + cursor position).
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = function()
      local t = vim.fn.getcmdtype()
      if t == "/" or t == "?" then
        state.searching = false
        state.pattern = ""
        vim.schedule(refresh)
      end
    end,
  })
end

return M
