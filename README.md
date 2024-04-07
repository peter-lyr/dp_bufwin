# dp_bufwin

```lua
{
  'git@github.com:peter-lyr/dp_bufwin',
  keys = {
    { '<leader>w', desc = 'winbuf', },
  },
  config = function()
    require 'dp_bufwin'.setup()
  end,
}
```

setup defaults:

```lua
local dp_win = require 'dp_win'
-- local dp_buf = require 'dp_buf'

{
  ['<leader>'] = {
    w = {
      name = 'winbuf',
      e = { dp_win.win_equal, 'win: equal', mode = { 'n', 'v', }, },
      m = { dp_win.win_max_height, 'win: max height', mode = { 'n', 'v', }, },
      h = { dp_win.win_go_left, 'win: go left', mode = { 'n', 'v', }, },
      j = { dp_win.win_go_down, 'win: go down', mode = { 'n', 'v', }, },
      k = { dp_win.win_go_up, 'win: go up', mode = { 'n', 'v', }, },
      l = { dp_win.win_go_right, 'win: go right', mode = { 'n', 'v', }, },
      -- ...
    },
  },
}
```
