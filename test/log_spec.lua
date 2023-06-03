return function()
  local mock_fs = require("deftest.mock.fs")
  local log = require("modules.log")

  describe("log", function()
    before(function()
      log.set_level(log.DEBUG)

      mock_fs.mock()
    end)

    after(function()
      mock_fs.unmock()
    end)

    describe("set_level", function()
      it("sets the log level, which prevents lower-level logs from being written", function()
        log.set_level(log.WARN)
        local path = log.info("info message")
        assert_nil(path)

        log.set_level(log.INFO)
        local path = log.info("info message")
        assert_match("info message", mock_fs.get_file(path))
      end)
    end)

    describe("debug", function()
      it("writes a debug log to disk", function()
        local path = log.debug("debug message")
        assert_match("- DEBUG - .* - debug message", mock_fs.get_file(path))
      end)
    end)

    describe("info", function()
      it("writes an info log to disk", function()
        local path = log.info("info message")
        assert_match("- INFO  - .* - info message", mock_fs.get_file(path))
      end)
    end)

    describe("warn", function()
      it("writes a warning log to disk", function()
        local path = log.warn("warning message")
        assert_match("- WARN  - .* - warning message", mock_fs.get_file(path))
      end)
    end)

    describe("error", function()
      it("writes an error log to disk", function()
        local path = log.error("error message")
        assert_match("- ERROR - .* - error message", mock_fs.get_file(path))
      end)
    end)

    describe("fatal", function()
      it("writes a fatal log to disk", function()
        local path = log.fatal("fatal message")
        assert_match("- FATAL - .* - fatal message", mock_fs.get_file(path))
      end)
    end)
  end)
end
