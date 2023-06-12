----------------------------------------------------------------------------------------------------
-- Camera: Camera module, built on top of Defold Orthographic.
----------------------------------------------------------------------------------------------------

local ids = require("modules.ids")
local camera = require("orthographic.camera")

local M = {}

M.zoom = 5

----------------------------------------------------------------------------------------------------
-- Internal API
----------------------------------------------------------------------------------------------------

local function get_scaling_factor()
  if not defos then
    return 1
  end

  local displays = defos.get_displays()
  if not displays or #displays == 0 then
    return 1
  end

  local main_display = displays[1]
  return main_display.mode and main_display.mode.scaling_factor or 1
end

----------------------------------------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------------------------------------

--- Initialize camera to follow the player.
--- @param options table Table with camera options
function M.init(options)
  camera.set_zoom(ids.CAMERA_ID, options.zoom)
  camera.follow(ids.CAMERA_ID, ids.PLAYER_ID, {
    lerp = 0.1,
  })
end

--- Set bounds for camera.
function M.set_bounds(x, y, w, h)
  camera.bounds(ids.CAMERA_ID, x, h, w, y)
end

--- Update scaling factor on every tick.
function M.update()
  local scaling_factor = get_scaling_factor()
  camera.set_window_scaling_factor(scaling_factor)
end

return M
