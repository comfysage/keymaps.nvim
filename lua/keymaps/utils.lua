local M = {}

function M.key_hook(props)
  if type(props) == "string" then
    return props
  end
  if type(props) == "table" then
    local keys = ""
    for _, k in ipairs(props) do
      keys = keys .. (keymaps_config.special_keys[k] or k)
    end
    return keys
  end
end

return M
