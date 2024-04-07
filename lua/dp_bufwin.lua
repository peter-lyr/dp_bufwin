local M = {}

local dp_win = require 'dp_win'
local dp_buf = require 'dp_buf'

M.defaults = {
  ['<leader>'] = {
    w = {
      name = 'winbuf',
      e = { dp_win.win_equal, 'win: equal', mode = { 'n', 'v', }, },
      m = { dp_win.win_max_height, 'win: max height', mode = { 'n', 'v', }, },
    },
  },
}

function M.setup(options)
  require 'which-key'.register(vim.tbl_deep_extend('force', {}, M.defaults, options or {}))
end

return M
