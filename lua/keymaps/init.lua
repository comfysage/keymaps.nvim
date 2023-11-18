---@class KeymapsConfig
---@field default_opts {}

---@type KeymapsConfig
local default_config = {
  default_opts = {
    silent = true,
    noremap = true,
  }
}

_G.keymaps_config = _G.keymaps_config or default_config

local Keymaps = require 'keymaps.prototype'

---@type { normal: table, visual: table, insert: table }
_G.keymaps = _G.keymaps or Keymaps.new {
  { 'normal', 'n' },
  { 'visual', 'v' },
  { 'insert', 'i' },
}

local M = {}

---@param config KeymapsConfig|nil
function M.setup(config)
  _G.keymaps_config = vim.tbl_deep_extend("force", _G.keymaps_config, config or {})
  return _G.keymaps
end

return M
