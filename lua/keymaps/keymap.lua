---@class keymaps.types.keymap
---@field __index keymaps.types.keymap
---@field mode string
---@field lhs string
---@field rhs keymaps.types.rhs
---@field desc string
---@field opts vim.api.keyset.keymap
---@field group? string

---@alias keymaps.types.rhs string|function

---@class vim.api.keyset.keymap
---@field overwrite boolean
---@field buffer integer

---@type keymaps.types.keymap
local Keymap = {}

Keymap.__index = Keymap

---@alias keymaps.types.value { [1]: keymaps.types.rhs, [2]: string|nil, [3]: vim.api.keyset.keymap|nil, group?: string }

---@class keymaps.types.keymap
---@field new fun(self: keymaps.types.keymap, mode: string, key: string, value: keymaps.types.value): keymaps.types.keymap
function Keymap:new(mode, key, value)
  ---@type keymaps.types.keymap
  local map = {
    mode = mode,
    lhs = key,
    opts = {},
    desc = '',
    rhs = '',
  }
  if type(value) == 'table' then
    map.rhs = value[1]
    map.desc = value[2] or ''
    map.group = value.group or nil
    map.opts = vim.tbl_deep_extend(
      'force',
      _G.keymaps_config.default_opts,
      value[3] or {}
    )

    if map.opts.overwrite then
      Keymap.overwrite(map)
    end

    if map.opts.buffer then
      vim.api.nvim_create_autocmd('BufDelete', {
        group = _G.keymaps_config._augroup,
        buffer = map.opts.buffer,
        once = true,
        desc = 'clean up keymaps prototype after buffer deletion',
        callback = function()
          local maps = require('keymaps.data').get_maps_by_mode(map.mode)
          maps:remove(map.lhs)
        end,
      })
    end
  elseif type(value) == 'string' then
    map.rhs = value
  elseif type(value) == 'function' then
    map.rhs = value
  else
    return
  end
  if map.desc == '' then
    if map.opts.desc then
      map.desc = map.opts.desc
    elseif type(map.rhs) == 'string' then
      ---@diagnostic disable-next-line: assign-type-mismatch
      map.desc = map.rhs
    end
  end
  map.opts.desc = map.desc

  local keymap = setmetatable(map, self)

  return keymap
end

---@class keymaps.types.keymap
---@field overwrite fun(self: keymaps.types.keymap)
function Keymap:overwrite()
  local old_maps = vim.api.nvim_get_keymap 'n'
  local old_map = vim.tbl_filter(function(t)
    return t.lhs == self.lhs
  end, old_maps)
  if #old_map > 0 then
    vim.keymap.del(self.mode, self.lhs)
  end
  ---@diagnostic disable-next-line: inject-field
  self.opts.overwrite = nil
end

---@class keymaps.types.keymap
---@field enable fun(self: keymaps.types.keymap)
function Keymap:enable()
  vim.validate {
    mode = { self.mode, 'string' },
    lhs = { self.lhs, 'string' },
    rhs = { self.rhs, { 'string', 'function' } },
    opts = { self.opts, { 'table' } },
  }
  vim.keymap.set(self.mode, self.lhs, self.rhs, self.opts)
end

return Keymap
