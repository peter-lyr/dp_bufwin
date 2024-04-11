local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

if B.check_plugins {
      -- 'git@github.com:peter-lyr/dp_init',
      'folke/which-key.nvim',
    } then
  return
end

B.merge_other_functions(M, {
  require 'dp_bufwin.win',
  require 'dp_bufwin.buf',
  require 'dp_bufwin.fontsize',
})

M.defaults = {
  ['<leader>'] = {
    w = {
      name = 'winbuf',
      [';'] = { function() M.toggle_max_height() end, 'win: auto max height toggle', mode = { 'n', 'v', }, },
      e = { function() M.win_equal() end, 'win: equal', mode = { 'n', 'v', }, },
      m = { function() M.win_max_height() end, 'win: max height', mode = { 'n', 'v', }, },
      h = { function() M.win_go 'h' end, 'win: go left', mode = { 'n', 'v', }, },
      j = { function() M.win_go 'j' end, 'win: go down', mode = { 'n', 'v', }, },
      k = { function() M.win_go 'k' end, 'win: go up', mode = { 'n', 'v', }, },
      l = { function() M.win_go 'l' end, 'win: go right', mode = { 'n', 'v', }, },
      a = { function() M.change_around 'h' end, 'exchange with window: left', mode = { 'n', 'v', }, },
      s = { function() M.change_around 'j' end, 'exchange with window: down', mode = { 'n', 'v', }, },
      w = { function() M.change_around 'k' end, 'exchange with window: up', mode = { 'n', 'v', }, },
      d = { function() M.change_around 'l' end, 'exchange with window: right', mode = { 'n', 'v', }, },
      z = { function() M.go_last_window() end, 'go window: right below', mode = { 'n', 'v', }, },
      t = { '<c-w>t', 'go window: topleft', mode = { 'n', 'v', }, },
      q = { '<c-w>p', 'go window: toggle', mode = { 'n', 'v', }, },
      n = { '<c-w>w', 'go window: next', mode = { 'n', 'v', }, },
      g = { '<c-w>W', 'go window: prev', mode = { 'n', 'v', }, },
      u = { ':<c-u>leftabove new<cr>', 'create new window: up', mode = { 'n', 'v', }, },
      i = { ':<c-u>new<cr>', 'create new window: down', mode = { 'n', 'v', }, },
      o = { ':<c-u>leftabove vnew<cr>', 'create new window: left', mode = { 'n', 'v', }, },
      p = { ':<c-u>vnew<cr>', 'create new window: right', mode = { 'n', 'v', }, },
      ['<left>'] = { '<c-w>v<c-w>h', 'split window: up', mode = { 'n', 'v', }, },
      ['<down>'] = { '<c-w>s', 'split window: down', mode = { 'n', 'v', }, },
      ['<up>'] = { '<c-w>s<c-w>k', 'split window: left', mode = { 'n', 'v', }, },
      ['<right>'] = { '<c-w>v', 'split window: right', mode = { 'n', 'v', }, },
      c = { '<c-w>H', 'be most window: up', mode = { 'n', 'v', }, },
      v = { '<c-w>J', 'be most window: down', mode = { 'n', 'v', }, },
      f = { '<c-w>K', 'be most window: left', mode = { 'n', 'v', }, },
      b = { '<c-w>L', 'be most window: right', mode = { 'n', 'v', }, },
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
  ['<c-cr>'] = { function() M.split_all_other_proj_buffer() end, 'split all other proj buffer', mode = { 'n', 'v', }, },
  ['<c-/>'] = { function() M.just_split_other_proj_buffer() end, 'just split other proj buffer', mode = { 'n', 'v', }, },
  ['<c-space>'] = { function() M.open_other_proj_buffer() end, 'open other proj buffer', mode = { 'n', 'v', }, },
  ['<a-h>'] = { function() vim.cmd 'wincmd <' end, 'window: width less 1', mode = { 'n', 'v', }, silent = true, },
  ['<a-l>'] = { function() vim.cmd 'wincmd >' end, 'window: width more 1', mode = { 'n', 'v', }, silent = true, },
  ['<a-j>'] = { function() vim.cmd 'wincmd -' end, 'window: height less 1', mode = { 'n', 'v', }, silent = true, },
  ['<a-k>'] = { function() vim.cmd 'wincmd +' end, 'window: height more 1', mode = { 'n', 'v', }, silent = true, },
  ['<a-s-h>'] = { function() vim.cmd '10wincmd <' end, 'window: width less 10', mode = { 'n', 'v', }, silent = true, },
  ['<a-s-l>'] = { function() vim.cmd '10wincmd >' end, 'window: width more 10', mode = { 'n', 'v', }, silent = true, },
  ['<a-s-j>'] = { function() vim.cmd '10wincmd -' end, 'window: height less 10', mode = { 'n', 'v', }, silent = true, },
  ['<a-s-k>'] = { function() vim.cmd '10wincmd +' end, 'window: height more 10', mode = { 'n', 'v', }, silent = true, },
  ['<c-0>'] = { name = 'bufwin font size', },
  ['<c-0><c-0>'] = { function() M.fontsize_normal() end, 'bufwin font size:  min', mode = { 'n', 'v', }, silent = true, },
  ['<c-0>_'] = { function() M.fontsize_min() end, 'bufwin font size: min', mode = { 'n', 'v', }, silent = true, },
  ['<c-0><c-->'] = { function() M.fontsize_frameless() end, 'bufwin font size: frameless', mode = { 'n', 'v', }, silent = true, },
  ['<c-0><c-=>'] = { function() M.fontsize_fullscreen() end, 'bufwin font size: fullscreen', mode = { 'n', 'v', }, silent = true, },
  ['<c-->'] = { function() M.fontsize_down() end, 'bufwin font size: down', mode = { 'n', 'v', }, silent = true, },
  ['<c-=>'] = { function() M.fontsize_up() end, 'bufwin font size: up', mode = { 'n', 'v', }, silent = true, },
  ['<c-ScrollWheelDown>'] = { function() M.fontsize_down() end, 'bufwin font size: down', mode = { 'n', 'v', }, silent = true, },
  ['<c-ScrollWheelUp>'] = { function() M.fontsize_up() end, 'bufwin font size: up', mode = { 'n', 'v', }, silent = true, },
  ['<c-MiddleMouse>'] = { function() M.fontsize_normal() end, 'bufwin font size: min', mode = { 'n', 'v', }, silent = true, },
}

function M.setup(options)
  require 'which-key'.register(vim.tbl_deep_extend('force', {}, M.defaults, options or {}))
end

return M
