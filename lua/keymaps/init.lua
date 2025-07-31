---@class KeymapsConfig.spec
---@field default_opts? {}
---@field special_keys? { [string]: string }

---@class KeymapsConfig : KeymapsConfig.spec
---@field default_opts {}
---@field special_keys { [string]: string }
---@field _augroup integer

---@type KeymapsConfig.spec
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

---@type KeymapsConfig
vim.g.keymaps_config = vim.g.keymaps_config or default_config

local Keymaps = require 'keymaps.prototype'

---@type { normal: table, visual: table, insert: table }
_G.keymaps = vim.g.keymaps or Keymaps:new {
  { 'normal',   'n' },
  { 'visual',   'v' },
  { 'insert',   'i' },
  { 'terminal', 't' },
}

local M = {}

---@param config? KeymapsConfig.spec
function M.setup(config)
  vim.g.keymaps_config = vim.tbl_deep_extend("force", vim.g.keymaps_config, config or {})
  vim.g.keymaps_config._augroup = vim.api.nvim_create_augroup('keymaps:autocmds', {clear = true})
  return _G.keymaps
end

function M.telescope()
  local ok, _ = pcall(require, 'telescope')
  if not ok then
    vim.notify('telescope module was not found; install telescope from https://github.com/nvim-telescope/telescope.nvim', vim.log.levels.WARN)
    return
  end
  return require 'telescope'.extensions.keymaps_nvim.keymaps_nvim()
end

return M
