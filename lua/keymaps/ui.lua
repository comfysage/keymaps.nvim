local M = {}

local ngram_highlighter = function(ngram_len, prompt, display)
  local highlights = {}
  display = display:lower()

  for disp_index = 1, #display do
    local char = display:sub(disp_index, disp_index + ngram_len - 1)
    if prompt:find(char, 1, true) then
      table.insert(highlights, {
        start = disp_index,
        finish = disp_index + ngram_len - 1,
      })
    end
  end

  return highlights
end

local make_displayer = function()
	return require 'telescope.pickers.entry_display'.create {
  separator = " ",
  items = {
    { width = 6 },
    { width = 20 },
    { width = 12 },
    { remaining = true },
  },
}
end

local make_sorter = function(opts)
  opts = opts or {}

  local ngram_len = opts.ngram_len or 2

  local cached_ngrams = {}
  local function overlapping_ngrams(s, n)
    if cached_ngrams[s] and cached_ngrams[s][n] then
      return cached_ngrams[s][n]
    end

    local R = {}
    for i = 1, s:len() - n + 1 do
      R[#R + 1] = s:sub(i, i + n - 1)
    end

    if not cached_ngrams[s] then
      cached_ngrams[s] = {}
    end

    cached_ngrams[s][n] = R

    return R
  end

  return require 'telescope.sorters'.Sorter:new {
    -- self
    -- prompt (which is the text on the line)
    -- line (entry.ordinal)
    -- entry (the whole entry)
    scoring_function = function(_, prompt, entry, _)
      if prompt == 0 or #prompt < ngram_len then
        return 1
      end
      local line = entry[2].lhs

      local prompt_lower = prompt:lower()
      local line_lower = line:lower()

      local prompt_ngrams = overlapping_ngrams(prompt_lower, ngram_len)

      local N = #prompt

      local mode_specific = prompt_lower:find(' ', 1, true)
      if mode_specific then
        local selected_mode = string.sub(prompt_lower, 1, mode_specific-1)

        local current_mode = entry[1]
        local current_group = (entry[2].group or ''):lower()

        local mode_match = selected_mode == current_mode
        local group_match = selected_mode == current_group

        if (not mode_match) and (not group_match) then
          return -1
        end
        prompt_lower = string.sub(prompt_lower, mode_specific+1)
      end

      local contains_string = line_lower:find(prompt_lower, 1, true)

      local consecutive_matches = 0
      local previous_match_index = 0
      local match_count = 0

      for i = 1, #prompt_ngrams do
        local match_start = line_lower:find(prompt_ngrams[i], 1, true)
        if match_start then
          match_count = match_count + 1
          if match_start > previous_match_index then
            consecutive_matches = consecutive_matches + 1
          end

          previous_match_index = match_start
        end
      end

      -- TODO: Copied from ashkan.
      local denominator = (
        (10 * match_count / #prompt_ngrams)
        -- biases for shorter strings
        -- TODO(ashkan): this can bias towards repeated finds of the same
        -- subpattern with overlapping_ngrams
        + 3 * match_count * ngram_len / #line
        + consecutive_matches
        + N / (contains_string or (2 * #line)) -- + 30/(c1 or 2*N)

      )

      if denominator == 0 or denominator ~= denominator then
        return -1
      end

      if #prompt > 2 and denominator < 0.5 then
        return -1
      end

      return 1 / denominator
    end,

    highlighter = opts.highlighter or function(_, prompt, display)
      return ngram_highlighter(ngram_len, prompt, display)
    end,
  }
end

local make_display = function(entry)
  return make_displayer() {
    { entry.value[1],             '@namespace' },
    { entry.value[2].lhs,         '@field' },
    { entry.value[2].group or "", '@type' },
    { entry.value[2].desc,        '@comment' },
  }
end

function M.telescope(opts)
  local _, status = pcall(require, 'telescope')
  if not status then return end

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'

  local modes = _G.keymaps.prototype.modes

  local results = {}

  local i = 0
  for _, mode in ipairs(vim.tbl_keys(modes)) do
    for _, keybind in ipairs(vim.tbl_values(_G.keymaps.prototype[mode])) do
      i = i + 1
      results[i] = { mode, keybind }
    end
  end


  local picker = pickers.new(opts, {
    results_title = 'Keymaps',
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = entry,
        }
      end,
    },
    sorter = make_sorter {},
  })

  picker:find()
end

return M
