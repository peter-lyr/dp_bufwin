local M = {}

function M.win_equal()
  vim.cmd 'wincmd ='
end

function M.win_max_height()
  vim.cmd 'wincmd _'
end

M.defaults = {
  ['<leader>'] = {
    w = {
      name = 'winbuf',
      e = { M.win_equal, 'win equal', mode = { 'n', 'v', }, },
      m = { M.win_max_height, 'win max height', mode = { 'n', 'v', }, },
    },
  },
}

function M.setup(options)
  require 'which-key'.register(vim.tbl_deep_extend('force', {}, M.defaults, options or {}))
end

return M
