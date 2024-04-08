local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

if B.check_plugins {
  'folke/which-key.nvim',
} then return end

B.merge_other_functions(M, {
  require 'dp_bufwin.win',
  require 'dp_bufwin.buf',
})

M.defaults = {
  ['<leader>'] = {
    w = {
      name = 'winbuf',
      e = { function() M.win_equal() end, 'win: equal', mode = { 'n', 'v', }, },
      m = { function() M.win_max_height() end, 'win: max height', mode = { 'n', 'v', }, },
      h = { function() M.win_go 'h' end, 'win: go left', mode = { 'n', 'v', }, },
      j = { function() M.win_go 'j' end, 'win: go down', mode = { 'n', 'v', }, },
      k = { function() M.win_go 'k' end, 'win: go up', mode = { 'n', 'v', }, },
      l = { function() M.win_go 'l' end, 'win: go right', mode = { 'n', 'v', }, },
    },
    x = {
      name = 'winbuf.close',
      c = { function() M.win_close() end, 'win.close:  cur', mode = { 'n', 'v', }, },
      h = { function() M.win_close 'h' end, 'win.close: left', mode = { 'n', 'v', }, },
      j = { function() M.win_close 'j' end, 'win.close: close down', mode = { 'n', 'v', }, },
      k = { function() M.win_close 'k' end, 'win.close : up', mode = { 'n', 'v', }, },
      l = { function() M.win_close 'l' end, 'win.close : right', mode = { 'n', 'v', }, },
      o = {
        name = 'winbuf.close.other',
        c = { function() vim.cmd 'wincmd o' end, 'win.close.other: windows in cur tab ', mode = { 'n', 'v', }, },
        t = { function() vim.cmd 'tabonly' end, 'win.close.other: windows in other tabs ', mode = { 'n', 'v', }, },
        a = { function() vim.cmd 'tabonly|wincmd o' end, 'win.close.other: all windows ', mode = { 'n', 'v', }, },
      },
    },
  },
}

function M.setup(options)
  require 'which-key'.register(vim.tbl_deep_extend('force', {}, M.defaults, options or {}))
end

return M
