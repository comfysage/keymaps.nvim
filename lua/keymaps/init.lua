---@class KeymapsConfig
---@field default_opts {}
---@field special_keys { [string]: string }

---@type KeymapsConfig
local default_config = {
  default_opts = {
    silent = true,
    noremap = true,
  },
  special_keys = {
    ['SPC'] = "<space>",
    ['TAB'] = "<TAB>",
  },
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

function M.telescope()
  local ok, telescope = pcall(require, 'telescope')
  if not ok then
    vim.notify('telescope module was not found; install telescope from https://github.com/nvim-telescope/telescope.nvim', vim.log.levels.WARN)
    return
  end
  return require 'telescope'.extensions.keymaps_nvim.keymaps_nvim()
end

return M
