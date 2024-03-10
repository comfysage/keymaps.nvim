local M = {}

---@return string[]
function M.get_modes()
  local modes = {}
  ---@diagnostic disable-next-line: undefined-field
  for m, _ in pairs(keymaps.modes) do
    modes[#modes+1] = m
  end
  return modes
end

---@param mode string
---@return keymaps.types.keymaplist
function M.get_mode(mode)
  return keymaps[mode]
end

---@param mode string
---@return table<string, keymaps.types.keymap>
function M.get_maps(mode)
  local list = M.get_mode(mode)
  return list.list
end

---@return string[]
function M.get_groups()
  local groups = {}

  local modes = M.get_modes()
  for _, mode in pairs(modes) do
    local mappings = M.get_maps(mode)
    for _, v in pairs(mappings) do
      if v.group and #v.group > 0 then
        groups[v.group] = true
      end
    end
  end

  local _groups = {}
  for k, _ in pairs(groups) do
    _groups[#_groups+1] = k
  end

  return _groups
end

---@param name string
---@return table[]
function M.get_group(name)
  local maps = {}

  local modes = M.get_modes()
  for _, mode in pairs(modes) do
    maps[mode] = {}
    local mappings = M.get_maps(mode)
    for _, v in pairs(mappings) do
      if v.group == name then
        maps[mode][#maps[mode]+1] = v
      end
    end
  end
  return maps
end

---@param mapping Keymap
function M.get_mapping(mapping)
  mapping = mapping or {}

  local modes = M.get_modes()
  for _, mode in pairs(modes) do
    local mappings = M.get_maps(mode)
    for _, v in pairs(mappings) do
      local match = 0
      for k, _ in pairs(mapping) do
        if v[k] and mapping[k] == v[k] then
          match = match + 1
        end
      end
      if match == #vim.tbl_keys(mapping) then
        return v
      end
    end
  end
end

return M
