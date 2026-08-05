--- Browser-style back/forward navigation through visited files.
---
--- A Lua port of https://github.com/ckarnell/history-traverse.
---
--- Each window keeps its own history: a list of file paths plus an index
--- pointing at the current entry. Visiting a file truncates anything ahead of
--- the index and appends — exactly like a browser dropping its forward stack
--- once you follow a new link. New windows (splits, tabs) inherit a copy of the
--- history from the window you came from, so a split starts where you left off
--- and can still go back.
---
--- Unlike the jumplist (<C-o>/<C-i>) this is per *file*, not per cursor
--- position, so one press moves one file no matter how much you jumped around
--- inside it.
local M = {}

---@class lib.history_traverse.Opts
---@field ft_ignore string[] filetypes never recorded (and that back() jumps out of)
---@field fn_ignore string[] file name tails never recorded
---@field max_len integer maximum entries kept per window
M.opts = {
  ft_ignore = {},
  fn_ignore = {},
  max_len = 100,
}

---@class lib.history_traverse.State
---@field list string[] visited file paths, oldest first
---@field index integer 1-based position in `list`; 0 when empty

---@type table<integer, lib.history_traverse.State> keyed by window id
local states = {}

--- Snapshot of the last window we left, used to seed newly created windows.
---@type lib.history_traverse.State?
local inherited = nil

--- Set while traversing so the BufWinEnter autocmd doesn't record the jump
--- itself as a new visit (which would clobber the forward history).
local skip = false

---@param win integer
---@return lib.history_traverse.State
local function state_of(win)
  local st = states[win]
  if not st then
    -- First time in this window: inherit both directions from wherever we came
    -- from, or start empty.
    st = inherited and { list = vim.deepcopy(inherited.list), index = inherited.index }
      or { list = {}, index = 0 }
    states[win] = st
  end
  return st
end

--- Buffers we refuse to track: anything that isn't a real, named file, plus the
--- user's ignore lists. back() also treats these as "not part of the history",
--- so pressing back from one returns to the last real file.
---@param buf integer
---@return boolean
local function is_ignored(buf)
  if vim.bo[buf].buftype ~= "" then
    return true
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return true
  end
  -- Things that aren't a file on disk but still reach us with an empty
  -- 'buftype': URI-scheme buffers (oil://, fugitive://) and directories. Oil in
  -- particular only sets buftype=acwrite *after* BufWinEnter has fired, so the
  -- check above doesn't catch it.
  if name:match("^%w[%w+.%-]*://") or vim.fn.isdirectory(name) == 1 then
    return true
  end
  return vim.tbl_contains(M.opts.ft_ignore, vim.bo[buf].filetype)
    or vim.tbl_contains(M.opts.fn_ignore, vim.fn.fnamemodify(name, ":t"))
end

--- Switch the current window to `path`, preferring an already-loaded buffer so
--- the window's remembered cursor position for that file is restored.
---@param path string
---@return boolean ok, string? err
local function goto_path(path)
  skip = true
  local ok, err = pcall(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == path then
        vim.api.nvim_win_set_buf(0, buf)
        return
      end
    end
    vim.cmd.edit(vim.fn.fnameescape(path))
  end)
  skip = false
  return ok, err
end

--- Record a visit to `path` in the current window's history.
---@param path string
function M.add(path)
  if skip or path == "" then
    return
  end

  local st = state_of(vim.api.nvim_get_current_win())

  -- Re-entering the current file (e.g. :e!) changes nothing.
  if st.list[st.index] == path then
    return
  end

  -- Landing on what is already the next entry (say, via :bnext) walks forward
  -- rather than truncating the forward history.
  if st.list[st.index + 1] == path then
    st.index = st.index + 1
    return
  end

  -- A genuinely new destination: drop the forward history and append.
  for i = #st.list, st.index + 1, -1 do
    table.remove(st.list, i)
  end
  table.insert(st.list, path)
  st.index = #st.list

  local overflow = #st.list - M.opts.max_len
  if overflow > 0 then
    for _ = 1, overflow do
      table.remove(st.list, 1)
    end
    st.index = st.index - overflow
  end
end

--- Move to the previous file in this window's history.
function M.back()
  local st = state_of(vim.api.nvim_get_current_win())

  -- Sitting in an untracked buffer (oil, help, a terminal): "back" means
  -- returning to the last real file, without spending a history step.
  if is_ignored(vim.api.nvim_get_current_buf()) and st.list[st.index] then
    goto_path(st.list[st.index])
    return
  end

  if st.index <= 1 then
    vim.notify("No previous file", vim.log.levels.WARN)
    return
  end

  local ok, err = goto_path(st.list[st.index - 1])
  if ok then
    st.index = st.index - 1
  else
    -- The edit failed (unsaved changes, deleted file, ...) so stay put.
    vim.notify(tostring(err), vim.log.levels.ERROR)
  end
end

--- Move to the next file in this window's history.
function M.forward()
  local st = state_of(vim.api.nvim_get_current_win())

  if st.index >= #st.list then
    vim.notify("No next file", vim.log.levels.WARN)
    return
  end

  local ok, err = goto_path(st.list[st.index + 1])
  if ok then
    st.index = st.index + 1
  else
    vim.notify(tostring(err), vim.log.levels.ERROR)
  end
end

---@return boolean
function M.can_back()
  local st = states[vim.api.nvim_get_current_win()]
  return st ~= nil and st.index > 1
end

---@return boolean
function M.can_forward()
  local st = states[vim.api.nvim_get_current_win()]
  return st ~= nil and st.index < #st.list
end

--- Statusline indicator, e.g. for a lualine component.
---@param icons? { back_active: string, back_inactive: string, forward_active: string, forward_inactive: string, separator: string }
---@return string
function M.indicator(icons)
  icons = vim.tbl_extend("force", {
    back_active = vim.fn.nr2char(0x2B05), -- ⬅
    back_inactive = vim.fn.nr2char(0x21E6), -- ⇦
    forward_active = vim.fn.nr2char(0x27A1), -- ➡
    forward_inactive = vim.fn.nr2char(0x21E8), -- ⇨
    separator = " ",
  }, icons or {})
  return (M.can_back() and icons.back_active or icons.back_inactive)
    .. icons.separator
    .. (M.can_forward() and icons.forward_active or icons.forward_inactive)
end

---@param opts? lib.history_traverse.Opts
function M.setup(opts)
  M.opts = vim.tbl_extend("force", M.opts, opts or {})

  local group = vim.api.nvim_create_augroup("history_traverse", { clear = true })

  -- A buffer became visible in a window: that's a visit.
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(event)
      if not is_ignored(event.buf) then
        M.add(vim.api.nvim_buf_get_name(event.buf))
      end
    end,
  })

  -- Claim the inherited history as soon as a new window is entered, rather than
  -- waiting for its first visit — a `:split` of the buffer already on screen
  -- records no visit, but the split can still go back.
  vim.api.nvim_create_autocmd("WinEnter", {
    group = group,
    callback = function()
      state_of(vim.api.nvim_get_current_win())
    end,
  })

  -- Remember the history of the window we're leaving so a window created from
  -- here (split, new tab) starts with the same back/forward stack.
  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    callback = function()
      inherited = states[vim.api.nvim_get_current_win()]
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(event)
      states[tonumber(event.match)] = nil
    end,
  })
end

return M
