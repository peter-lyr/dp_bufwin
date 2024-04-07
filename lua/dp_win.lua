local M = {}

function M.win_equal()
  vim.cmd 'wincmd ='
end

function M.win_max_height()
  vim.cmd 'wincmd _'
end

return M
