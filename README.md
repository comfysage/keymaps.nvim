## Installation

using `lazy.nvim`:
```lua
return {
    'crispybaccoon/keymaps.nvim',
    priority = 2000, -- load before setting keymaps
    opts = {
      -- default options given to `vim.keymap.set()`
      default_opts = {
        silent = true,
        noremap = true,
      },
    },
}
```

## usage

first run:

```lua
require 'keymaps'.setup {}
```

at the beggining of your config.

or using a protected call:

```lua
local ok, keymaps = pcall(require, 'keymaps')
if ok then keymaps.setup {} end
```

then your can use the 'keymaps' global like this:

```lua
-- keymaps <mode> [<key>]        { <keymap>         <description>  }
keymaps.normal['<space><TAB>'] = { ":$tabedit<CR>", 'Open New Tab' }

-- possible modes are: normal, visual and insert

-- the keymap can also be a lua function, like this:
keymaps.normal["<C-t>"] = {
  function() require 'telescope.builtin'.colorscheme() end,
  'Find Colorscheme'
}
-- uses [@telescope](https://github.com/nvim-telescope/telescope.nvim)

-- you can also pass additional options to the keymaps
keymaps.normal["gg"] = { '<cmd>call smoothie#do("gg") <CR>', 'Scroll to top of file', { overwrite = true } }
keymaps.normal["G"] = { '<cmd>call smoothie#do("G") <CR>', 'Scroll to bottom of file', { overwrite = true } }
-- uses [@vim-smoothie](https://github.com/psliwka/vim-smoothie)

-- keymaps can also be grouped by passing a name to the `group` property:
keymaps.normal[',hp'] = { require 'gitsigns'.preview_hunk, '[Git] Preview Hunk', group = 'Git' }
keymaps.normal[',hs'] = { require 'gitsigns'.stage_hunk, '[Git] stage current hunk', group = 'Git' }
-- uses [@gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
```

### Telescope Integration

Add the following to your nvim config to load the telescope extension
```lua
require 'telescope'.load_extension 'keymaps_nvim'
```

to view your keymaps using telescope run the following
```lua
require 'telescope'.extensions.keymaps_nvim.keymaps_nvim()
```
