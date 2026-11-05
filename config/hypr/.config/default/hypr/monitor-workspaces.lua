-- Per-monitor workspaces with Omarchy's opt-out, ported from omacom/omarchy#16213.
--
-- Omarchy 4.5 requires default/hypr/monitor-workspaces.lua unconditionally, so
-- this file shadows it (bootstrap searches ~/.config/?.lua before
-- $OMARCHY_PATH/?.lua) and reads the opt-out the PR adds:
-- ~/.local/state/omarchy/toggles/no-monitor-workspaces.
--
-- With the flag absent, load the packaged module unchanged. With it present,
-- use Hyprland's global workspace ids instead. Retire this file and the
-- omarchy-toggle-monitor-workspaces command once #16213 ships.

local paths = require("default.hypr.paths")

local function opted_out()
  local flag = io.open(paths.state_home .. "/omarchy/toggles/no-monitor-workspaces", "r")
  if not flag then
    return false
  end

  flag:close()
  return true
end

if not opted_out() then
  local M = dofile(paths.omarchy_path .. "/default/hypr/monitor-workspaces.lua")
  -- The installed module predates the PR's flag; the bindings read it.
  M.enabled = true
  return M
end

local SLOTS = 10

-- The stock bar labels workspaces from the monitor block map this feature
-- writes. Remove it in global mode so the bar falls back to the global ids.
local function forget_blocks()
  os.remove(paths.state_home .. "/omarchy/monitor-workspaces")
  os.remove(paths.state_home .. "/omarchy/monitor-workspaces-merged")
end

local M = { slots = SLOTS, enabled = false }

-- The keybindings menu replays a function bind by dispatching this expression.
local function action(fn, expression)
  o.bind_expressions[fn] = expression
  return fn
end

local function literal(value)
  return string.format("%q", value)
end

-- Go to global workspace `slot`, on a named monitor when the bar asks for one.
function M.focus(slot, monitor_name)
  return action(function()
    local monitor = monitor_name and hl.get_monitor(monitor_name) or nil
    if monitor and not monitor.focused then
      hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
    end

    hl.dispatch(hl.dsp.focus({ workspace = tostring(slot) }))
  end, "o.workspaces.focus(" .. slot .. (monitor_name and ", " .. literal(monitor_name) or "") .. ")")
end

-- Move the active window to global workspace `slot`, following it unless false.
function M.move_window(slot, follow)
  return action(function()
    local window = hl.get_active_window()
    if not window then
      return
    end

    hl.dispatch(hl.dsp.window.move({
      workspace = tostring(slot),
      follow = follow ~= false,
      window = "address:" .. window.address,
    }))
  end, "o.workspaces.move_window(" .. slot .. (follow == false and ", false" or "") .. ")")
end

-- Move the active workspace to the monitor in a direction; its id stays global.
function M.move_to_monitor(direction)
  return action(function()
    local workspace = hl.get_active_workspace()
    local target = hl.get_monitor(direction)
    if not workspace or workspace.special or workspace.id <= 0 or not target then
      return
    end

    hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(workspace.id), monitor = target.name }))
  end, "o.workspaces.move_to_monitor(" .. literal(direction) .. ")")
end

-- Move the focused window to the monitor in a direction, following it.
function M.move_window_to_monitor(direction)
  return action(function()
    local target = hl.get_monitor(direction)
    if target then
      hl.dispatch(hl.dsp.window.move({ monitor = target.name }))
    end
  end, "o.workspaces.move_window_to_monitor(" .. literal(direction) .. ")")
end

forget_blocks()
o.workspaces = M
return M
