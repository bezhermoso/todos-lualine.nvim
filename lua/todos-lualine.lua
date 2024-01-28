-- main module file
local component = require("todos-lualine.component")

---@class TodosLualineModule
local M = {}

---@param args ComponentConfig?
---@return function
M.component = function(args)
  return component.component(args or {})
end

return M
