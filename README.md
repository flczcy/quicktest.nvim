# Quicktest

Quicktest improves your testing experience in real-time with flexible display options like popups or split windows, customized to your workflow preferences. Key features include identifying the nearest function and triggering its test, rerunning previous tests from any location, and live scrolling of results alongside a running timer for immediate feedback.

Currently supported languages: Go, Typescript/Javascript(vitest), Elixir, Dart, C(criterion). There is also a template in Readme below about how to create own adapter. Should be pretty easy, just shell command execute!

https://github.com/user-attachments/assets/9fcb3e17-f521-4660-9d9a-d9f763de5a1b

## Features

- **Contextual Test Triggering:** Run tests directly from where your cursor is located or execute all tests in the entire file/dir/project.
- **Flexible Test Reruns:** Rerun tests from any location(with `require('quicktest').run_previous()`), automatically opening window or using an existing if it's open.
- **Live-Scrolling Results:** Continuously scroll through test results as they are generated. But stop scrolling if you decided to scroll up.
- **Real-Time Feedback:** View the results of tests immediately as they run, without waiting for the completion of the test suite.
- **Test Duration Timer:** Display a timer to monitor the duration of ongoing tests.
- **ANSI colors:** Just supported.
- **Easy API for adapters:** It's just all about running cmd and piping results to `quicktest`.

If these features resonate with you, Quicktest might be just what you need!

## Api

```lua
local qt = require 'quicktest'

-- Choose your adapter, here all supported adapters are listed
qt.setup({
  adapters = {
    require("quicktest.adapters.golang")({
      additional_args = function(bufnr) return { '-race', '-count=1' } end
      -- bin = function(bufnr) return 'go' end
      -- cwd = function(bufnr) return 'your-cwd' end
    }),
    require("quicktest.adapters.vitest")({
      ---@class VitestAdapterOptions
      ---@field cwd (fun(bufnr: integer, current: string?): string)?
      ---@field bin (fun(bufnr: integer, current: string?): string)?
      ---@field config_path (fun(bufnr: integer, current: string): string)?
      ---@field args (fun(bufnr: integer, current: string[]): string[])?
      ---@field env (fun(bufnr: integer, current: table<string, string>): table<string, string>)?
      ---@field is_enabled (fun(bufnr: integer, type: RunType, current: boolean): boolean)?

      -- bin = function(bufnr, current) return current end
      -- cwd = function(bufnr, current) return current end
      -- config_path = function(bufnr, current) return current end
    }),
    require("quicktest.adapters.elixir"),
    require("quicktest.adapters.criterion")({
      builddir = function(bufnr) return "build" end,
      additional_args = function(bufnr) return {'arg1', 'arg2'} end,
    }),
    require("quicktest.adapters.dart"),
  },
  -- split or popup mode, when argument not specified
  default_win_mode = "split",
  -- Baleia make coloured output. Requires baleia package. Can cause crashes https://github.com/quolpr/quicktest.nvim/issues/11
  use_baleia = false
})

-- Find nearest test under cursor and run in popup
qt.run_line('popup')
-- Find nearest test under cursor and run in split
qt.run_line('split')
-- Find nearest test under cursor and run in currently opened window(popup or split)
qt.run_line()

-- Run all tests of file in popup/split
qt.run_file('popup')
qt.run_file('split')
qt.run_line()

-- Run all tests of current file dir in popup/split
qt.run_dir('popup')
qt.run_dir('split')
qt.run_dir()

-- Run all tests of project in popup/split
qt.run_all('popup')
qt.run_all('split')
qt.run_all()

-- Open or close split/popup if already opened, without running tests.
-- Just open and close window.
qt.toggle_win('popup')
qt.toggle_win('split')

-- Take previous test run and run in popup/split
qt.run_previous('popup')
qt.run_previous('split')
qt.run_previous()
```

## Installation

Supported languages: Go, Typescript/Javascript(vitest), C (criterion with meson), Dart<br>
Feel free to open PR for your language, the plugin API is pretty simple and described in `Building your own plugin` section in this Readme.

Simple configurations:

```lua
local qt = require("quicktest")

-- Choose your adapter, here all supported adapters are listed
qt.setup({
  adapters = {
    require("quicktest.adapters.golang"),
    require("quicktest.adapters.vitest")({
      -- bin = function(bufnr) return 'vitest' end
      -- cwd = function(bufnr) return bufnr end
      -- config_path = function(bufnr) return 'vitest.config.js' end
    }),
    require("quicktest.adapters.elixir"),
    require("quicktest.adapters.criterion"),
    require("quicktest.adapters.dart"),
  },
  -- split or popup mode, when argument not specified
  default_win_mode = "split",
  -- Baleia make coloured output. Requires baleia package. Can cause crashes https://github.com/quolpr/quicktest.nvim/issues/11
  use_baleia = false
})

vim.keymap.set("n", "<leader>tl", qt.run_line, {
  desc = "[T]est Run [L]line",
})
vim.keymap.set("n", "<leader>tf", qt.run_file, {
  desc = "[T]est Run [F]ile",
})
vim.keymap.set("n", "<leader>td", qt.run_dir, {
  desc = "[T]est Run [D]ir",
})
vim.keymap.set("n", "<leader>ta", qt.run_all, {
  desc = "[T]est Run [A]ll",
})
vim.keymap.set("n", "<leader>tR", qt.run_previous, {
  desc = "[T]est Run [P]revious",
})
-- vim.keymap.set("n", "<leader>tt", function()
--   qt.toggle_win("popup")
-- end, {
--   desc = "[T]est [T]oggle popup window",
-- })
vim.keymap.set("n", "<leader>tt", function()
  qt.toggle_win("split")
end, {
  desc = "[T]est [T]oggle Window",
})
vim.keymap.set("n", "<leader>tc", function()
  qt.cancel_current_run()
end, {
  desc = "[T]est [C]ancel Current Run",
})
```

Using Lazy:

```lua
{
  "quolpr/quicktest.nvim",
  config = function()
    local qt = require("quicktest")

    qt.setup({
      -- Choose your adapter, here all supported adapters are listed
      adapters = {
        require("quicktest.adapters.golang")({
          additional_args = function(bufnr) return { '-race', '-count=1' } end
          -- bin = function(bufnr) return 'go' end
          -- cwd = function(bufnr) return 'your-cwd' end
        }),
        require("quicktest.adapters.vitest")({
          -- bin = function(bufnr) return 'vitest' end
          -- cwd = function(bufnr) return bufnr end
          -- config_path = function(bufnr) return 'vitest.config.js' end
        }),
        require("quicktest.adapters.elixir"),
        require("quicktest.adapters.criterion"),
        require("quicktest.adapters.dart"),
      },
      -- split or popup mode, when argument not specified
      default_win_mode = "split",
      -- Baleia make coloured output. Requires baleia package. Can cause crashes https://github.com/quolpr/quicktest.nvim/issues/11
      use_baleia = false
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    -- "m00qek/baleia.nvim",
  },
  keys = {
    {
      "<leader>tl",
      function()
        local qt = require("quicktest")
        -- current_win_mode return currently opened panel, split or popup
        qt.run_line()
        -- You can force open split or popup like this:
        -- qt.run_line('split')
        -- qt.run_line('popup')
      end,
      desc = "[T]est Run [L]line",
    },
    {
      "<leader>tf",
      function()
        local qt = require("quicktest")

        qt.run_file()
      end,
      desc = "[T]est Run [F]ile",
    },
    {
      '<leader>td',
      function()
        local qt = require 'quicktest'

        qt.run_dir()
      end,
      desc = '[T]est Run [D]ir',
    },
    {
      '<leader>ta',
      function()
        local qt = require 'quicktest'

        qt.run_all()
      end,
      desc = '[T]est Run [A]ll',
    },
    {
      "<leader>tp",
      function()
        local qt = require("quicktest")

        qt.run_previous()
      end,
      desc = "[T]est Run [P]revious",
    },
    {
      "<leader>tt",
      function()
        local qt = require("quicktest")

        qt.toggle_win("split")
      end,
      desc = "[T]est [T]oggle Window",
    },
    {
      "<leader>tc",
      function()
        local qt = require("quicktest")

        qt.cancel_current_run()
      end,
      desc = "[T]est [C]ancel Current Run",
    },
  },
}
```


## Screenshots

### Running test in split window
<img width="1074" alt="image" src="https://github.com/user-attachments/assets/2d14d302-2b48-49b3-bdbd-1c2c2dd0a893">

### Running test in popup window
<img width="1074" alt="image" src="https://github.com/user-attachments/assets/13109577-77f6-48c2-b6eb-326e27891331">

### Canceled test
<img width="1074" alt="Screenshot 2024-07-28 at 22 38 42" src="https://github.com/user-attachments/assets/fe1cf395-c5b7-4846-9ffa-2521a875e423">

## Building your own adapter

Here is the template of how adapter for any language could be written. For more examples just check `lua/quicktest/adapters`. For tresitter methods investigation you can take code from adapters of neotest from https://github.com/nvim-neotest/neotest?tab=readme-ov-file#supported-runners

```lua
local Job = require("plenary.job")

local M = {
  name = "myadapter",
}
---@class MyRunParams
---@field func_names string[]
---@field bufnr integer
---@field cursor_pos integer[]

--- Optional:
--- Builds parameters for running tests based on buffer number and cursor position.
--- This function should be customized to extract necessary information from the buffer.
---@param bufnr integer
---@param cursor_pos integer[]
---@return MyRunParams, nil | string
-- M.build_line_run_params = function(bufnr, cursor_pos)
--   -- You can get current function name to run based on bufnr and cursor_pos
--   -- Check hot it is done for golang at `lua/quicktest/adapters/golang`
--   return {
--     bufnr = bufnr,
--     cursor_pos = cursor_pos,
--     func_names = {},
--     -- Add other parameters as needed
--   }, nil
-- end

--- Optional:
---@param bufnr integer
---@param cursor_pos integer[]
---@return MyRunParams, nil | string
-- M.build_file_run_params = function(bufnr, cursor_pos)
--   return {
--     bufnr = bufnr,
--     cursor_pos = cursor_pos,
--     -- Add other parameters as needed
--   }, nil
-- end

--- Optional:
---@param bufnr integer
---@param cursor_pos integer[]
---@return MyRunParams, nil | string
-- M.build_dir_run_params = function(bufnr, cursor_pos)
--   return {
--     bufnr = bufnr,
--     cursor_pos = cursor_pos,
--     -- Add other parameters as needed
--   }, nil
-- end

--- Optional:
---@param bufnr integer
---@param cursor_pos integer[]
---@return MyRunParams, nil | string
-- M.build_all_run_params = function(bufnr, cursor_pos)
--   return {
--     bufnr = bufnr,
--     cursor_pos = cursor_pos,
--     -- Add other parameters as needed
--   }, nil
-- end

--- Executes the test with the given parameters.
---@param params MyRunParams
---@param send fun(data: any)
---@return integer
M.run = function(params, send)
  local job = Job:new({
    command = "test_command",
    args = { "--some-flag" }, -- Modify based on how your test command needs to be structured
    on_stdout = function(_, data)
      send({ type = "stdout", output = data })
    end,
    on_stderr = function(_, data)
      send({ type = "stderr", output = data })
    end,
    on_exit = function(_, return_val)
      send({ type = "exit", code = return_val })
    end,
  })

  job:start()

  return job.pid
end

--- Optional: title of the test run
---@param params MyRunParams
-- M.title = function(params)
--   return "Running test"
-- end

--- Optional: handles actions to take after the test run, based on the results.
---@param params any
---@param results any
-- M.after_run = function(params, results)
--   -- Implement actions based on the results, such as updating UI or handling errors
-- end

--- Checks if the adapter is enabled for the given buffer.
---@param bufnr integer
---@return boolean
M.is_enabled = function(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  return vim.endswith(bufname, "test.ts") or vim.endswith(bufname, "test.js")
end

return M
```
