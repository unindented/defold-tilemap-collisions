return function()
  local mock = require("deftest.mock.mock")
  local utils = require("modules.utils")

  describe("utils", function()
    before(function()
      mock.mock(os)
      mock.mock(sys)
    end)

    after(function()
      mock.unmock(os)
      mock.unmock(sys)
    end)

    describe("starts_with", function()
      it("returns true if string starts with", function()
        assert_true(utils.starts_with("abcde", "ab"))
      end)

      it("returns false if string doesn't start with", function()
        assert_false(utils.starts_with("abcde", "bc"))
      end)
    end)

    describe("ends_with", function()
      it("returns true if string ends with", function()
        assert_true(utils.ends_with("abcde", "de"))
      end)

      it("returns false if string doesn't end with", function()
        assert_false(utils.ends_with("abcde", "cd"))
      end)
    end)

    describe("version", function()
      it("returns a version string", function()
        local pattern = "%w+ v%d%.%d%\nDefold v%d%.%d%.%d %(%w+%)"
        assert_match(pattern, utils.version())
      end)
    end)

    describe("is_debug", function()
      it("returns true if this is a debug build", function()
        sys.get_engine_info.always_returns({ is_debug = true })
        assert_true(utils.is_debug())
      end)

      it("returns false if this isn't a debug build", function()
        sys.get_engine_info.always_returns({ is_debug = false })
        assert_false(utils.is_debug())
      end)
    end)

    describe("platform", function()
      it("returns the platform name", function()
        sys.get_sys_info.always_returns({ system_name = "Linux" })
        assert_equal("Linux", utils.platform())
      end)
    end)

    describe("config_path", function()
      it("returns the config path for a file when platform isn't Linux", function()
        sys.get_config.always_returns("My Awesome App!")
        sys.get_sys_info.always_returns({ system_name = "Windows" })
        sys.get_save_file.replace(function(dirname, filename)
          return "/some/path/" .. dirname .. "/" .. filename
        end)
        assert_equal("/some/path/MyAwesomeApp/config.dat", utils.config_path("config.dat"))
      end)

      it(
        "returns the config path for a file when platform is Linux, XDG_CONFIG_HOME isn't defined, and HOME isn't defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.always_returns(nil)
          assert_equal("/some/path/MyAwesomeApp/config.dat", utils.config_path("config.dat"))
        end
      )

      it(
        "returns the config path for a file when platform is Linux, XDG_CONFIG_HOME isn't defined, and HOME is defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "HOME" then
              return "/home/path"
            end
            return nil
          end)
          assert_equal(
            "/home/path/.config/MyAwesomeApp/config.dat",
            utils.config_path("config.dat")
          )
        end
      )

      it(
        "returns the config path for a file when platform is Linux, XDG_CONFIG_HOME is defined but isn't absolute, and HOME is not defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "XDG_CONFIG_HOME" then
              return ".myconfig"
            end
            return nil
          end)
          assert_equal("/some/path/MyAwesomeApp/config.dat", utils.config_path("config.dat"))
        end
      )

      it(
        "returns the config path for a file when platform is Linux, XDG_CONFIG_HOME is defined but isn't absolute, and HOME is defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "XDG_CONFIG_HOME" then
              return ".myconfig"
            end
            if varname == "HOME" then
              return "/home/path"
            end
            return nil
          end)
          assert_equal(
            "/home/path/.config/MyAwesomeApp/config.dat",
            utils.config_path("config.dat")
          )
        end
      )

      it(
        "returns the config path for a file when platform is Linux, XDG_CONFIG_HOME is defined and is absolute",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "XDG_CONFIG_HOME" then
              return "/home/path/.myconfig"
            end
            return nil
          end)
          assert_equal(
            "/home/path/.myconfig/MyAwesomeApp/config.dat",
            utils.config_path("config.dat")
          )
        end
      )
    end)

    describe("data_path", function()
      it("returns the data path for a file when platform isn't Linux", function()
        sys.get_config.always_returns("My Awesome App!")
        sys.get_sys_info.always_returns({ system_name = "Windows" })
        sys.get_save_file.replace(function(dirname, filename)
          return "/some/path/" .. dirname .. "/" .. filename
        end)
        assert_equal("/some/path/MyAwesomeApp/data.dat", utils.data_path("data.dat"))
      end)

      it(
        "returns the data path for a file when platform is Linux, XDG_DATA_HOME isn't defined, and HOME isn't defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.always_returns(nil)
          assert_equal("/some/path/MyAwesomeApp/data.dat", utils.data_path("data.dat"))
        end
      )

      it(
        "returns the data path for a file when platform is Linux, XDG_DATA_HOME isn't defined, and HOME is defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "HOME" then
              return "/home/path"
            end
            return nil
          end)
          assert_equal("/home/path/.local/share/MyAwesomeApp/data.dat", utils.data_path("data.dat"))
        end
      )

      it(
        "returns the data path for a file when platform is Linux, XDG_DATA_HOME is defined but isn't absolute, and HOME is not defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "XDG_DATA_HOME" then
              return ".mylocal/share"
            end
            return nil
          end)
          assert_equal("/some/path/MyAwesomeApp/data.dat", utils.data_path("data.dat"))
        end
      )

      it(
        "returns the data path for a file when platform is Linux, XDG_DATA_HOME is defined but isn't absolute, and HOME is defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "XDG_DATA_HOME" then
              return ".mylocal/share"
            end
            if varname == "HOME" then
              return "/home/path"
            end
            return nil
          end)
          assert_equal("/home/path/.local/share/MyAwesomeApp/data.dat", utils.data_path("data.dat"))
        end
      )

      it(
        "returns the data path for a file when platform is Linux, XDG_DATA_HOME is defined and is absolute",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "XDG_DATA_HOME" then
              return "/home/path/.mylocal/share"
            end
            return nil
          end)
          assert_equal(
            "/home/path/.mylocal/share/MyAwesomeApp/data.dat",
            utils.data_path("data.dat")
          )
        end
      )
    end)

    describe("state_path", function()
      it("returns the state path for a file when platform isn't Linux", function()
        sys.get_config.always_returns("My Awesome App!")
        sys.get_sys_info.always_returns({ system_name = "Windows" })
        sys.get_save_file.replace(function(dirname, filename)
          return "/some/path/" .. dirname .. "/" .. filename
        end)
        assert_equal("/some/path/MyAwesomeApp/state.dat", utils.state_path("state.dat"))
      end)

      it(
        "returns the state path for a file when platform is Linux, XDG_STATE_HOME isn't defined, and HOME isn't defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.always_returns(nil)
          assert_equal("/some/path/MyAwesomeApp/state.dat", utils.state_path("state.dat"))
        end
      )

      it(
        "returns the state path for a file when platform is Linux, XDG_STATE_HOME isn't defined, and HOME is defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "HOME" then
              return "/home/path"
            end
            return nil
          end)
          assert_equal(
            "/home/path/.local/state/MyAwesomeApp/state.dat",
            utils.state_path("state.dat")
          )
        end
      )

      it(
        "returns the state path for a file when platform is Linux, XDG_STATE_HOME is defined but isn't absolute, and HOME is not defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "XDG_STATE_HOME" then
              return ".mylocal/state"
            end
            return nil
          end)
          assert_equal("/some/path/MyAwesomeApp/state.dat", utils.state_path("state.dat"))
        end
      )

      it(
        "returns the state path for a file when platform is Linux, XDG_STATE_HOME is defined but isn't absolute, and HOME is defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "XDG_STATE_HOME" then
              return ".mylocal/state"
            end
            if varname == "HOME" then
              return "/home/path"
            end
            return nil
          end)
          assert_equal(
            "/home/path/.local/state/MyAwesomeApp/state.dat",
            utils.state_path("state.dat")
          )
        end
      )

      it(
        "returns the state path for a file when platform is Linux, XDG_STATE_HOME is defined and is absolute",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "XDG_STATE_HOME" then
              return "/home/path/.mylocal/state"
            end
            return nil
          end)
          assert_equal(
            "/home/path/.mylocal/state/MyAwesomeApp/state.dat",
            utils.state_path("state.dat")
          )
        end
      )
    end)

    describe("cache_path", function()
      it("returns the cache path for a file when platform isn't Linux", function()
        sys.get_config.always_returns("My Awesome App!")
        sys.get_sys_info.always_returns({ system_name = "Windows" })
        sys.get_save_file.replace(function(dirname, filename)
          return "/some/path/" .. dirname .. "/" .. filename
        end)
        assert_equal("/some/path/MyAwesomeApp/cache.dat", utils.cache_path("cache.dat"))
      end)

      it(
        "returns the cache path for a file when platform is Linux, XDG_CACHE_HOME isn't defined, and HOME isn't defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.always_returns(nil)
          assert_equal("/some/path/MyAwesomeApp/cache.dat", utils.cache_path("cache.dat"))
        end
      )

      it(
        "returns the cache path for a file when platform is Linux, XDG_CACHE_HOME isn't defined, and HOME is defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "HOME" then
              return "/home/path"
            end
            return nil
          end)
          assert_equal("/home/path/.cache/MyAwesomeApp/cache.dat", utils.cache_path("cache.dat"))
        end
      )

      it(
        "returns the cache path for a file when platform is Linux, XDG_CACHE_HOME is defined but isn't absolute, and HOME is not defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "XDG_CACHE_HOME" then
              return ".mycache"
            end
            return nil
          end)
          assert_equal("/some/path/MyAwesomeApp/cache.dat", utils.cache_path("cache.dat"))
        end
      )

      it(
        "returns the cache path for a file when platform is Linux, XDG_CACHE_HOME is defined but isn't absolute, and HOME is defined",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "XDG_CACHE_HOME" then
              return ".mycache"
            end
            if varname == "HOME" then
              return "/home/path"
            end
            return nil
          end)
          assert_equal("/home/path/.cache/MyAwesomeApp/cache.dat", utils.cache_path("cache.dat"))
        end
      )

      it(
        "returns the cache path for a file when platform is Linux, XDG_CACHE_HOME is defined and is absolute",
        function()
          sys.get_config.always_returns("My Awesome App!")
          sys.get_sys_info.always_returns({ system_name = "Linux" })
          sys.get_save_file.replace(function(dirname, filename)
            return "/some/path/" .. dirname .. "/" .. filename
          end)
          os.getenv.replace(function(varname)
            if varname == "XDG_CACHE_HOME" then
              return "/home/path/.mycache"
            end
            return nil
          end)
          assert_equal("/home/path/.mycache/MyAwesomeApp/cache.dat", utils.cache_path("cache.dat"))
        end
      )
    end)
  end)
end
