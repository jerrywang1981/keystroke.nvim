local vim = vim
local M = {}

M.sep = (function()
  if jit then
    local os = string.lower(jit.os)
    if os ~= "windows" then
      return "/"
    else
      return "\\"
    end
  else
    return package.config:sub(1, 1)
  end
end)()

M.join = function(...)
  return table.concat({ ... }, M.sep)
end

return M
