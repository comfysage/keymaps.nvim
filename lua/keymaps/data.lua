local M = {}

---@return string[]
function M.get_modes()
  local modes = {}
  for m, _ in pairs(keymaps.prototype.modes) do
    modes[#modes+1] = m
  end
  return modes
end

---@param mode string
---@return table[]
function M.get_mode(mode)
  return keymaps.prototype[mode]
end

---@param name string
---@return table[]
function M.get_group(name)
  local maps = {}

  local modes = M.get_modes()
  for _, mode in pairs(modes) do
    maps[mode] = {}
    local mappings = M.get_mode(mode)
    for _, v in pairs(mappings) do
      if v.group == name then
        maps[mode][#maps[mode]+1] = v
      end
    end
  end
  return maps
end

return M
