Keymaps = Keymaps or {}

---@class Keymap
---@field mode string
---@field lhs string
---@field rhs string|function
---@field desc string
---@field group string|nil

Keymaps.mt = {}

---@type { [string]: { [string]: Keymap }, modes: { [string]: string } }
Keymaps.prototype = {}
Keymaps.prototype.modes = {}

Keymaps.mt.__index = function (_, modename)
  local mt = {
    __index = function (_, key)
      if Keymaps.prototype[modename] then
        return Keymaps.prototype[modename][key]
      end
    end,
    __newindex = Keymaps.setter(modename),
  }
  local t = {}
  setmetatable(t, mt)
  return t
end

Keymaps.setter = function (modename)
  return function (_, key, v)
    Keymaps.set(modename, key, v)
  end
end

---@param modename any
---@param key any
---@param value { [1]: function|string, [2]: string|nil, [3]: table|nil, group: string|nil }
Keymaps.set = function (modename, key, value)
  if not _G.keymaps.prototype[modename] then return end

  local mode = _G.keymaps.prototype.modes[modename]
  ---@type Keymap
  local map = {
    mode = mode,
    lhs = key,
    opts = {},
    desc = '',
    rhs = value,
  }
  if type(value) == "table" then
    map.rhs = value[1]
    map.desc = value[2] or ''

    map.opts = vim.tbl_deep_extend('force', _G.keymaps_config.default_opts, value[3] or {})
    if map.opts.overwrite then
      local old_maps = vim.api.nvim_get_keymap('n')
      local old_map = vim.tbl_filter(function (t)
        return t.lhs == map.lhs
      end, old_maps)
      if #old_map > 0 then
        vim.keymap.del(mode, map.lhs)
      end
    end
    map.opts.overwrite = nil

    map.group = value.group or nil
  elseif type(value) == "string" then
  else
    return
  end
  map.opts.desc = map.desc
  _G.keymaps.prototype[modename][key] = map
  vim.keymap.set(mode, map.lhs, map.rhs, map.opts)
end

Keymaps.new = function (modes)
  local km = {}
  km.prototype = Keymaps.prototype or {}
  setmetatable(km, Keymaps.mt)
  for _, mode in ipairs(modes) do
    km.prototype[mode[1]] = Keymaps.prototype[mode[1]] or {}
    km.prototype.modes[mode[1]] = mode[2]
  end
  return km
end

return Keymaps
