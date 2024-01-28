---@class CustomModule
local M = {}

---@return string
M.my_first_function = function(greeting)
  return greeting
end

---@class ComponentConfig
local ComponentConfig = {
  glyphs = {
    TODO = { icon = "󰄬", enabled = true },
    FIX = { icon = "", enabled = true, alt = {"FIXME", "BUG", "FIXIT", "ISSUE"} },
    HACK = { icon = "󰈸", enabled = false },
    WARN = { icon = "", enabled = false, alt = {"WARNING"}, },
    NOTE = { icon = "󰎚", enabled = false, alt = {"INFO"}, },
    TEST = { icon = "", enabled = false, alt = {"TESTING", "PASSED", "FAILED"} },
  },
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
  for k, v in pairs(cfg.glyphs) do
    if v.enabled then
      table.insert(keywords, k)
      for _, alt in ipairs(v.alt or {}) do
        table.insert(keywords, alt)
      end
    end
  end

  args.keywords = table.concat(keywords, ",")
  vim.print(args)

  if args.keywords == "" then
    return args, false
  end

  return args, true
end

---@param cfg ComponentConfig
---@return table
local function build_count_table(cfg)
  local cnt_table = {}
  for k, v in pairs(cfg.glyphs) do
    if v.enabled then
      cnt_table[k] = 0
    end
  end
  return cnt_table
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
      local glyph = cfg.glyphs[k].icon or (k .. ":")
      local s = glyph .. " " .. count
      table.insert(segments, s)
    end
  end
  return table.concat(segments, " ") or cfg.when_empty or ""
end

---@param opts ComponentConfig
---@return function
M.component = function(opts)
  local cfg = ComponentConfig
  cfg = vim.tbl_deep_extend("force", cfg, opts or {})

  local started = false
  local output_str = ""

  local search_args, ok = build_search_args(cfg)
  if not ok then
    return function() return "..." end
  end

  -- This function will evaluated by Lualine at a set interval.
  return function()
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
