---@class keymaps.types.global
---@field __index keymaps.types.global
---@field modes table<string, string> -- { normal = 'n' }

local Keymaps = {}

Keymaps.__index = Keymaps

---@class keymaps.types.global
---@field new fun(self: keymaps.types.global, props): keymaps.types.global
function Keymaps:new(props)
  local _modes = {}
  for _, item in ipairs(props) do
    if #item == 2 then
      _modes[item[1]] = item[2]
    end
  end
  local _keymaps = setmetatable({
    modes = _modes,
  }, self)
  for mode, k in pairs(_modes) do
    _keymaps:append_mode { mode, k }
  end

  return _keymaps
end

---@class keymaps.types.global
---@field append_mode fun(self: keymaps.types.global, props)
function Keymaps:append_mode(props)
  if #props ~= 2 then return end
  local mode, k = unpack(props, 1, 2)
  self[mode] = require 'keymaps.keymaplist':new(k)
end

return Keymaps
