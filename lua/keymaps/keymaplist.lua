---@class keymaps.types.keymaplist
---@field __index keymaps.types.keymaplist
---@field mode string -- 'n'
---@field list table<string, keymaps.types.keymap>

---@type keymaps.types.keymaplist
local Keymaplist = {}

---@class keymaps.types.keymaplist
---@field new fun(self: keymaps.types.keymaplist, mode: string): keymaps.types.keymaplist
function Keymaplist:new(mode)
  local keymaplist = setmetatable({
    mode = mode,
    list = {},
  }, {
    __index = self,
    __newindex = function(this, key, value)
      return this:set(key, value)
    end,
  })

  return keymaplist
end

---@class keymaps.types.keymaplist
---@field set fun(self: keymaps.types.keymaplist, key: any, value: keymaps.types.value)
function Keymaplist:set(key, value)
  key = require('keymaps.utils').key_hook(key)
  if type(key) ~= 'string' then
    return
  end

  local map = require('keymaps.keymap'):new(self.mode, key, value)
  if not map then
    vim.notify(
      ('could not declare keymap for `%s`\n\t'):format(key)
        .. vim.inspect(value),
      vim.log.levels.ERROR
    )
    return
  end

  self.list[map.lhs] = map

  map:enable()
end

---@class keymaps.types.keymaplist
---@field get fun(self: keymaps.types.keymaplist, key: string): keymaps.types.keymap
function Keymaplist:get(key)
  return self.list[key]
end

---@class keymaps.types.keymaplist
---@field remove fun(self: keymaps.types.keymaplist, key: string): keymaps.types.keymap
function Keymaplist:remove(key)
  if self.list[key] then
    self.list[key] = nil
  end
end

return Keymaplist
