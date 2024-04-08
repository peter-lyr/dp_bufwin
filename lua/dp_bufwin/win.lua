local M = {}

function M.win_equal()
  vim.cmd 'wincmd ='
end

function M.win_max_height()
  local cur_winnr = vim.fn.winnr()
  local cur_wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
  local cur_start_col = cur_wininfo['wincol']
  local cur_end_col = cur_start_col + cur_wininfo['width']
  local winids = {}
  local winids_dict = {}
  for winnr = 1, vim.fn.winnr '$' do
    local wininfo = vim.fn.getwininfo(vim.fn.win_getid(winnr))[1]
    local start_col = wininfo['wincol']
    local end_col = start_col + wininfo['width']
    if start_col > cur_end_col or end_col < cur_start_col then
    else
      local winid = vim.fn.win_getid(winnr)
      if winnr ~= cur_winnr and vim.api.nvim_win_get_option(winid, 'winfixheight') == true then
        winids[#winids + 1] = winid
        winids_dict[winid] = wininfo['height']
      end
    end
  end
  vim.cmd 'wincmd _'
  for _, winid in ipairs(winids) do
    vim.api.nvim_win_set_height(winid, winids_dict[winid] + (#vim.o.winbar > 0 and 1 or 0))
  end
end

function M.win_go(dir)
  vim.cmd('wincmd ' .. dir)
end

function M.win_close(dir)
  local cur_winid = vim.fn.win_getid()
  if dir then
    M.win_go(dir)
  end
  local cur_winnr = vim.fn.winnr()
  for winnr = vim.fn.winnr '$', 1, -1 do
    if cur_winnr ~= winnr then
      if vim.fn.filereadable(vim.api.nvim_buf_get_name(vim.fn.winbufnr(winnr))) == 1 then
        vim.cmd 'close'
        break
      end
    end
  end
  if dir then
    vim.fn.win_gotoid(cur_winid)
  end
end

return M
