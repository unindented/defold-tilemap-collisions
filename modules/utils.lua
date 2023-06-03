----------------------------------------------------------------------------------------------------
-- Utils: All kinds of helpers.
----------------------------------------------------------------------------------------------------

local M = {}

----------------------------------------------------------------------------------------------------
-- String utils
----------------------------------------------------------------------------------------------------

--- Returns true if a string begins with the characters of a specified string.
--- @param str string String to search
--- @param search string String to be searched for
--- @return boolean
function M.starts_with(str, search)
  return string.sub(str, 1, #search) == search
end

--- Returns true if a string ends with the characters of a specified string.
--- @param str string String to search
--- @param search string String to be searched for
--- @return boolean
function M.ends_with(str, search)
  return search == "" or string.sub(str, -#search) == search
end

----------------------------------------------------------------------------------------------------
-- Misc utils
----------------------------------------------------------------------------------------------------

--- Return version information.
--- @return string
function M.version()
  local project_title = sys.get_config_string("project.title")
  local project_version = sys.get_config_string("project.version")
  local engine_info = sys.get_engine_info()
  local engine_version = engine_info.version
  local engine_sha1 = string.sub(engine_info.version_sha1, 1, 7)

  return project_title
    .. " v"
    .. project_version
    .. "\nDefold v"
    .. engine_version
    .. " ("
    .. engine_sha1
    .. ")"
end

--- Return whether this is a debug build.
--- @return boolean
function M.is_debug()
  local engine_info = sys.get_engine_info()
  return engine_info.is_debug
end

--- Return the platform name.
--- @return string
function M.platform()
  local sys_info = sys.get_sys_info()
  return sys_info.system_name
end

local function save_path(filename, xdg_varname, home_subdir)
  local appname = string.gsub(sys.get_config("project.title"), "%W", "")

  if M.platform() == "Linux" then
    local xdg_path = os.getenv(xdg_varname)
    local home_path = os.getenv("HOME")

    if xdg_path ~= nil and M.starts_with(xdg_path, "/") then
      return xdg_path .. "/" .. appname .. "/" .. filename
    end
    if home_path ~= nil then
      return home_path .. "/" .. home_subdir .. "/" .. appname .. "/" .. filename
    end
  end

  return sys.get_save_file(appname, filename)
end

--- Return the config path for a file.
--- @param filename string File name
--- @return string
function M.config_path(filename)
  return save_path(filename, "XDG_CONFIG_HOME", ".config")
end

--- Return the data path for a file.
--- @param filename string File name
--- @return string
function M.data_path(filename)
  return save_path(filename, "XDG_DATA_HOME", ".local/share")
end

--- Return the state path for a file.
--- @param filename string File name
--- @return string
function M.state_path(filename)
  return save_path(filename, "XDG_STATE_HOME", ".local/state")
end

--- Return the cache path for a file.
--- @param filename string File name
--- @return string
function M.cache_path(filename)
  return save_path(filename, "XDG_CACHE_HOME", ".cache")
end

return M
