---@class CustomModule
local M = {}

---@return string
M.my_first_function = function(greeting)
  return greeting
end

---@class ComponentConfig
local ComponentConfig = {
  keywords = {
    TODO = { icon = " " },
    FIX = { icon = " ", alt = {"FIXME", "BUG", "FIXIT", "ISSUE"} },
    HACK = { icon =  " " },
    WARN = { icon = "", alt = {"WARNING"}, },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", alt = {"INFO"}, },
    TEST = { icon =  "⏲ ", alt = {"TESTING", "PASSED", "FAILED"} },
  },
  order = { "TODO", "FIX" },
  when_empty = "",
}

---@param cfg ComponentConfig
---@return table, boolean
local function build_search_args(cfg)
  local args = {
    disable_not_found_warnings = true,
    keywords = "",
  }
  local keywords = {}
  for _, type in ipairs(cfg.order) do
    local kw = cfg.keywords[type]
    if kw ~= nil then
      table.insert(keywords, type)
      -- Some keywords have alternatives e.g. FIXME. Add those as well.
      for _, alt in ipairs(kw.alt or {}) do
        table.insert(keywords, alt)
      end
    else
      vim.notify("Keyword in component order " .. type .. " is not a known keyword.", vim.log.levels.ERROR)
      return args, false
    end
  end

  args.keywords = table.concat(keywords, ",")

  if args.keywords == "" then
    return args, false
  end

  return args, true
end

---@param cfg ComponentConfig
---@return table
local function build_count_table(cfg)
  local cnt_table = {}
  -- TODO: Validate ComponentConfig.order to contain only defined keywords.
  for _, v in ipairs(cfg.order) do
    cnt_table[v] = 0
  end
  return cnt_table
end

local function create_segment(type, keywords_entry, count)
  local glyph = keywords_entry.icon or (type .. ": ")
  local s = glyph .. count
  return s
end

---@param cfg ComponentConfig
---@return string
M.build_output_str_from_search_results = function(todos, cfg)
  -- A table of todo-type => int count e.g. { fix = 0, todo = 0, ... }
  local cnt_table = build_count_table(cfg)

  -- Loop through all todo-comments.nvim results and increment the appropriate counts in the table.
  for _, todo in ipairs(todos) do
    local k = todo.tag
    local count = cnt_table[k]
    if count ~= nil then
      cnt_table[k] = count + 1
    end
  end

  -- Next, build out the output string. Todo-types of count zero are excluded.
  local segments = {}
  for k, count in pairs(cnt_table) do
    if count > 0 then
      local s = create_segment(k, cfg.keywords[k], count)
      table.insert(segments, s)
    end
  end
  return table.concat(segments, " ") or cfg.when_empty or ComponentConfig.when_empty
end

local err_func = function() return "ERR!" end

---@param opts ComponentConfig
---@return function
M.component = function(opts)
  local cfg = ComponentConfig
  cfg = vim.tbl_deep_extend("force", cfg, opts or {})

  if #(cfg.order or {}) == 0 then
    vim.notify("todo-comments lualine order cannot be empty.", vim.log.levels.ERROR)
    return err_func
  end

  local started = false
  local output_str = ""

  local search_args, ok = build_search_args(cfg)
  if not ok then
    return err_func
  end

  -- This function will evaluated by Lualine at a set interval.
  return function()
    local config = require("todo-comments.config")
    if not config.loaded then
      return "..."
    end

    -- If started = true, it means search has started but the callback haven't received the results yet.
    if not started then
      started = true
      require("todo-comments.search").search(function (todos)
        -- Assign output_str for Lualine output, and mark started = false so
        -- next component eval triggers the search again.
        output_str = M.build_output_str_from_search_results(todos, cfg)
        started = false
      end, search_args)
    end
    return output_str
  end
end

return M
