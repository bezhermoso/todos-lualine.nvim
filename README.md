# ✅ todos-lualine.nvim

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/ellisonleao/nvim-plugin-template/lint-test.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

See the number of TODOs, HACKs, WARNs, NOTEs, etc. in your current workspace at a glance. An excellent companion for [folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim)

## Installation & Configuration

Via [`lazy.nvim`](https://github.com/folke/lazy.nvim):

Define this plugin as a dependency to `lualine.nvim`:

```lua
{
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = {
        { "bezhermoso/todos-lualine.nvim" },
        { "folke/todo-comments.nvim" } -- REQUIRED!
    },
    config = function ()
        -- Create the todos-lualine component:
        local todos_component = require("todos-lualine").component()
        require('lualine').setup({
            sections = {
                -- Add it to whichever section you'd like e.g. right next to "progress" on the right:
                lualine_y = {'progress', todos_component },
            }
        })
    end,
}
```

## Component Options

The `require("todos-lualine").component()` function accepts a configuration object of this form:

```lua
local config = {
  -- The todo-comments types to show & in what order:
  order = { "TODO", "FIX" },
  keywords = {
    -- The icon to show, as well as the keywords to classify under each todo-comments types.
    -- Identical to how you'd configure folke/todos-comments.nvim, actually.
    TODO = { icon = " " },
    FIX = { icon = " ", alt = {"FIXME", "BUG", "FIXIT", "ISSUE"} },
    HACK = { icon =  " " },
    WARN = { icon = "", alt = {"WARNING"} },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", alt = {"INFO"} },
    TEST = { icon =  "⏲ ", alt = {"TESTING", "PASSED", "FAILED"} },
  },
  when_empty = "",
}

ocal todos_comment = rquire("todos-lualine").component(config)
```
