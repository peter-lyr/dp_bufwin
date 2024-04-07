local M = {}

local dp_win = require 'dp_win'
local dp_buf = require 'dp_buf'

M.defaults = {
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
  },
}

function M.setup(options)
  require 'which-key'.register(vim.tbl_deep_extend('force', {}, M.defaults, options or {}))
end

return M
