--- Herdr session backend for sidekick.nvim.
---
--- Overlays sidekick without patching it: implements the `sidekick.cli.Session`
--- interface against the `herdr pane` CLI and registers itself via the public
--- `require("sidekick.cli.session").register()` hook. Sessions are *external*
--- (the agent runs in its own Herdr pane, not a Neovim terminal), so sidekick
--- never tries to embed a terminal — `cli.send()` routes text to the pane with
--- `herdr pane send-text`, and `submit` presses Enter with `herdr pane send-keys`.
---
--- Two ways a Herdr pane becomes a sidekick session:
---   1. auto  — any pane Herdr has detected an agent in (`PaneInfo.agent`)
---   2. bound — an explicit binding set via `bind()`/`bind_pick()`
---
---@class sidekick.cli.session.Herdr: sidekick.cli.Session
---@field herdr_pane_id string
local M = {}
M.__index = M

---@class sidekick.herdr.Opts
---@field default_tool string tool used for bound panes and unrecognised agents
M.opts = {
  default_tool = "claude",
}

--- Herdr agent id -> sidekick tool name (only where they differ).
local AGENT_ALIASES = {
  ["github-copilot"] = "copilot",
  ["amazon-q"] = "amazon_q",
}

---@type { pane_id: string, tool: string }?
M._bound = nil
M._registered = false

---@return string
local function herdr_bin()
  return vim.env.HERDR_BIN_PATH or "herdr"
end

---@param args string[]
---@return vim.SystemCompleted
local function exec(args)
  local cmd = { herdr_bin() }
  vim.list_extend(cmd, args)
  return vim.system(cmd, { text = true }):wait()
end

---Run a `herdr` command and return its decoded JSON `result` (nil on any
---failure) alongside the raw `vim.system` completion.
---@param args string[]
---@return table|nil result
---@return vim.SystemCompleted completed
local function run(args)
  local out = exec(args)
  if out.code ~= 0 or not out.stdout or out.stdout == "" then
    return nil, out
  end
  local ok, data = pcall(vim.json.decode, out.stdout)
  if not ok or type(data) ~= "table" then
    return nil, out
  end
  return data.result, out
end

---Return the current `PaneInfo[]` from `herdr pane list`, or `{}` on error.
---@return table[]
local function list_panes()
  local result = run({ "pane", "list" })
  if type(result) ~= "table" or type(result.panes) ~= "table" then
    return {}
  end
  return result.panes
end

---The Herdr pane Neovim itself runs in (never a send target / bind candidate).
---@return string|nil
local function self_pane_id()
  return vim.env.HERDR_PANE_ID
end

---Resolve a Herdr agent id to a configured sidekick tool name.
---@param agent string|nil
---@return string
local function tool_for(agent)
  local Config = require("sidekick.config")
  local name = agent and (AGENT_ALIASES[agent] or agent) or nil
  if name and Config.cli.tools[name] then
    return name
  end
  return M.opts.default_tool
end

--------------------------------------------------------------------------------
-- Session backend interface (called by sidekick core)
--------------------------------------------------------------------------------

--- A Herdr session descriptor: a sidekick `State` plus the Herdr pane
--- coordinates we attach so routing / `send` can target the exact pane.
---@class sidekick.herdr.State: sidekick.cli.session.State
---@field herdr_pane_id string
---@field herdr_tab_id? string
---@field priority? integer

---Build sidekick sessions from a `herdr pane list` snapshot.
---@param panes table[]
---@return sidekick.herdr.State[]
local function build_sessions(panes)
  local Config = require("sidekick.config")
  local me = self_pane_id()

  ---@type table<string, table>
  local by_id = {}
  for _, p in ipairs(panes) do
    by_id[p.pane_id] = p
  end

  local ret = {} ---@type sidekick.herdr.State[]
  local seen = {} ---@type table<string, boolean>

  ---@param pane_id string
  ---@param tool string
  local function add(pane_id, tool)
    if not pane_id or pane_id == me or seen[pane_id] then
      return
    end
    if not tool or not Config.cli.tools[tool] then
      return -- only surface panes that map to a configured tool
    end
    local p = by_id[pane_id]
    seen[pane_id] = true
    ret[#ret + 1] = {
      id = "herdr:" .. pane_id,
      cwd = (p and (p.foreground_cwd or p.cwd)) or "",
      herdr_pane_id = pane_id,
      herdr_tab_id = p and p.tab_id or nil,
      tool = tool,
      external = true, -- never opened in a Neovim terminal
      priority = 10,
    }
  end

  -- 1) panes Herdr has detected an agent in
  for _, p in ipairs(panes) do
    if type(p.agent) == "string" and p.agent ~= "" then
      add(p.pane_id, tool_for(p.agent))
    end
  end

  -- 2) explicit binding (dropped if the pane no longer exists)
  if M._bound then
    if by_id[M._bound.pane_id] then
      add(M._bound.pane_id, M._bound.tool or M.opts.default_tool)
    else
      M._bound = nil
    end
  end

  return ret
end

---Tab id of the Herdr pane Neovim runs in, from a pane-list snapshot.
---@param panes table[]
---@return string|nil
local function self_tab_id(panes)
  local me = self_pane_id()
  for _, p in ipairs(panes) do
    if p.pane_id == me then
      return p.tab_id
    end
  end
end

---@return sidekick.herdr.State[]
function M.sessions()
  if vim.env.HERDR_ENV ~= "1" then
    return {}
  end
  return build_sessions(list_panes())
end

---Paste literal text into the bound Herdr pane (bracketed-paste safe).
---@param text string
function M:send(text)
  if not self.herdr_pane_id then
    require("sidekick.util").warn("herdr: session has no pane; run :HerdrBind")
    return
  end
  exec({ "pane", "send-text", self.herdr_pane_id, text })
end

---Submit the pane's current input by sending Enter.
function M:submit()
  if not self.herdr_pane_id then
    return
  end
  exec({ "pane", "send-keys", self.herdr_pane_id, "Enter" })
end

---@return boolean
function M:is_running()
  if not self.herdr_pane_id then
    return false
  end
  for _, p in ipairs(list_panes()) do
    if p.pane_id == self.herdr_pane_id then
      return true
    end
  end
  return false
end

-- External sessions: the agent already lives in its own Herdr pane, so there is
-- nothing to attach/spawn inside Neovim. Returning nil keeps sidekick from
-- opening a terminal.
function M:attach() end
function M:detach() end
function M:start()
  require("sidekick.util").warn("herdr: no bound agent pane; run :HerdrBind first")
end

--------------------------------------------------------------------------------
-- Public API (binding + registration)
--------------------------------------------------------------------------------

---Issue an arbitrary `herdr` CLI command.
---Thin public wrapper over the internal runner: pass the args that follow the
---`herdr` binary and get back the decoded JSON `result` (nil on any failure)
---plus the raw completion for callers that need the exit code or stderr.
---@param args string[]
---@return table|nil result
---@return vim.SystemCompleted completed
function M.cli(args)
  return run(args)
end

---Whether Neovim is explicitly bound to a Herdr pane.
---@return boolean
function M.is_bound()
  return M._bound ~= nil
end

---Open a fresh Herdr pane running `tool`, bind Neovim to it, and return its
---pane id. The tool's configured `cmd` (with its flags) is used as the launch
---command, falling back to the bare tool name.
---@param opts? { tool?: string, ratio?: number, direction?: "right"|"down", focus?: boolean }
---@return string|nil pane_id
function M.spawn_agent(opts)
  opts = opts or {}
  if vim.env.HERDR_ENV ~= "1" then
    require("sidekick.util").warn("herdr: not running inside a Herdr session")
    return
  end
  local me = self_pane_id()
  if not me then
    require("sidekick.util").warn("herdr: unknown self pane (HERDR_PANE_ID unset)")
    return
  end

  local result = M.cli({
    "pane",
    "split",
    "--pane",
    me,
    "--direction",
    opts.direction or "right",
    "--ratio",
    tostring(opts.ratio or 0.75),
    opts.focus == false and "--no-focus" or "--focus",
  })
  local pane_id = type(result) == "table" and type(result.pane) == "table" and result.pane.pane_id
  if not pane_id then
    require("sidekick.util").warn("herdr: failed to open agent pane")
    return
  end

  -- Launch the tool in the new pane, preferring its configured cmd + flags.
  local tool = opts.tool or M.opts.default_tool
  local spec = require("sidekick.config").cli.tools[tool]
  local cmd = spec and spec.cmd
  local cmd_str = type(cmd) == "table" and table.concat(cmd, " ") or tool
  M.cli({ "pane", "run", pane_id, cmd_str })

  M.bind(pane_id, tool)
  return pane_id
end

---Whether at least one Herdr pane currently maps to a sidekick session.
---@return boolean
function M.has_session()
  return #M.sessions() > 0
end

---A precise `sidekick.cli.Filter` for routing a send to the Herdr pane, or nil
---when there is no Herdr target (caller should fall back to its own default).
--- - explicit binding                     -> that exact session, any tab
--- - one detected agent in Neovim's tab   -> that session (auto, no picker)
--- - otherwise                            -> any external Herdr session
---   (sidekick auto-picks a lone agent, else prompts)
---@return sidekick.cli.Filter|nil
function M.target_filter()
  if vim.env.HERDR_ENV ~= "1" then
    return nil
  end

  local panes = list_panes()
  local sessions = build_sessions(panes)
  if #sessions == 0 then
    return nil
  end

  -- explicit binding wins, regardless of tab
  if M._bound then
    for _, s in ipairs(sessions) do
      if s.herdr_pane_id == M._bound.pane_id then
        return { session = s.id }
      end
    end
  end

  -- exactly one agent sharing Neovim's Herdr tab -> auto-target it
  local tab = self_tab_id(panes)
  if tab then
    local same = {} ---@type sidekick.herdr.State[]
    for _, s in ipairs(sessions) do
      if s.herdr_tab_id == tab then
        same[#same + 1] = s
      end
    end
    if #same == 1 then
      return { session = same[1].id }
    end
  end

  return { external = true }
end

---Bind Neovim to a specific Herdr pane.
---@param pane_id string
---@param tool? string defaults to `opts.default_tool`
function M.bind(pane_id, tool)
  M._bound = { pane_id = pane_id, tool = tool or M.opts.default_tool }
  require("sidekick.util").info(("herdr: bound to `%s` (%s)"):format(pane_id, M._bound.tool))
end

function M.unbind()
  M._bound = nil
  require("sidekick.util").info("herdr: unbound")
end

---Pick a Herdr pane to bind via `vim.ui.select`. Only panes with a detected
---agent are offered (Neovim's own pane is always excluded).
function M.bind_pick()
  if vim.env.HERDR_ENV ~= "1" then
    require("sidekick.util").warn("herdr: not running inside a Herdr session")
    return
  end
  local me = self_pane_id()
  local candidates = {} ---@type table[]
  for _, p in ipairs(list_panes()) do
    if p.pane_id ~= me and type(p.agent) == "string" and p.agent ~= "" then
      candidates[#candidates + 1] = p
    end
  end
  if #candidates == 0 then
    require("sidekick.util").warn("herdr: no agent panes to bind to")
    return
  end
  vim.ui.select(candidates, {
    prompt = "Bind Herdr agent pane:",
    -- One row: `<pane_id>  <cwd>  <agent (status)>  [title]`. Candidates always
    -- have an agent, so the title is its task description, not a shell prompt.
    format_item = function(p)
      local cwd = vim.fn.fnamemodify(p.foreground_cwd or p.cwd or "?", ":~")
      local st = p.agent_status
      local agent = (st and st ~= "" and st ~= "unknown") and ("%s (%s)"):format(p.agent, st)
        or p.agent
      local row = ("%s  %s  %s"):format(p.pane_id, cwd, agent)
      local title = p.terminal_title_stripped or p.terminal_title
      if type(title) == "string" and title ~= "" then
        row = row .. "  " .. title
      end
      return row
    end,
  }, function(p)
    if p then
      M.bind(p.pane_id, tool_for(p.agent))
    end
  end)
end

---Register the backend into sidekick. Safe to call more than once.
---@param opts? sidekick.herdr.Opts
function M.setup(opts)
  M.opts = vim.tbl_extend("force", M.opts, opts or {})
  if not M._registered then
    require("sidekick.cli.session").register("herdr", M)
    M._registered = true
  end
  pcall(function()
    vim.api.nvim_create_user_command(
      "HerdrBindSidekick",
      M.bind_pick,
      { desc = "Herdr: bind agent pane" }
    )
    vim.api.nvim_create_user_command(
      "HerdrUnbindSidekick",
      M.unbind,
      { desc = "Herdr: unbind agent pane" }
    )
  end)
  return M
end

return M
