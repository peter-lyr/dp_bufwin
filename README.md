# dp_bufwin

```lua
{
  'git@github.com:peter-lyr/dp_bufwin',
  keys = {
    { '<leader>w', desc = 'winbuf', },
    { '<leader>x', desc = 'winbuf.close', },
  },
  config = function()
    require 'dp_bufwin'.setup()
  end,
}
```

setup defaults:

```lua
local dp_win = require 'dp_win'
local dp_buf = require 'dp_buf'

{
  ['<leader>'] = {
    w = {
      name = 'winbuf',
      e = { function() dp_win.win_equal() end, 'win: equal', mode = { 'n', 'v', }, },
      m = { function() dp_win.win_max_height() end, 'win: max height', mode = { 'n', 'v', }, },
      h = { function() dp_win.win_go 'h' end, 'win: go left', mode = { 'n', 'v', }, },
      j = { function() dp_win.win_go 'j' end, 'win: go down', mode = { 'n', 'v', }, },
      k = { function() dp_win.win_go 'k' end, 'win: go up', mode = { 'n', 'v', }, },
      l = { function() dp_win.win_go 'l' end, 'win: go right', mode = { 'n', 'v', }, },
    },
    x = {
      name = 'winbuf.close',
      c = { function() dp_win.win_close() end, 'win.close:  cur', mode = { 'n', 'v', }, },
      h = { function() dp_win.win_close 'h' end, 'win.close: left', mode = { 'n', 'v', }, },
      j = { function() dp_win.win_close 'j' end, 'win.close: close down', mode = { 'n', 'v', }, },
      k = { function() dp_win.win_close 'k' end, 'win.close : up', mode = { 'n', 'v', }, },
      l = { function() dp_win.win_close 'l' end, 'win.close : right', mode = { 'n', 'v', }, },
      o = {
        name = 'winbuf.close.other',
        c = { function() vim.cmd 'wincmd o' end, 'win.close.other: windows in cur tab ', mode = { 'n', 'v', }, },
        t = { function() vim.cmd 'tabonly' end, 'win.close.other: windows in other tabs ', mode = { 'n', 'v', }, },
        a = { function() vim.cmd 'tabonly|wincmd o' end, 'win.close.other: all windows ', mode = { 'n', 'v', }, },
      },
    },
  },
}
```
