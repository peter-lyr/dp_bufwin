local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

M.DoNotCloseFileTypes = {
  'NvimTree',
  'aerial',
  'qf',
  'fugitive',
}

M.proj_buffer = {}

M.max_height_en = nil

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
    if B.is_in_tbl(dir, { 'j', 'k', }) and M.max_height_en then
      if not B.is(vim.o.winfixheight) then
        M.win_max_height()
      end
    end
end

  function M.toggle_max_height()
    if M.max_height_en then
      vim.cmd 'wincmd ='
      M.max_height_en = nil
    else
      M.win_max_height()
      M.max_height_en = 1
    end
    B.echo('M.max_height_en: ' .. tostring(M.max_height_en))
  end

-- [ ] TODO: close 2 or more untitled buffers
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

B.aucmd({ 'BufEnter', }, 'my.bufwin.BufEnter', {
  callback = function(ev)
    local root = B.get_proj_root(B.buf_get_name(ev.buf))
    M.proj_buffer[root] = ev.buf
  end,
})

function M.close_except_fts()
  local to_close_winnr = {}
  local cur_winnr = vim.fn.winnr()
  for winnr = vim.fn.winnr '$', 1, -1 do
    if cur_winnr ~= winnr then
      local bufnr = vim.fn.winbufnr(winnr)
      if not B.is_in_tbl(vim.api.nvim_buf_get_option(bufnr, 'filetype'), M.DoNotCloseFileTypes) then
        to_close_winnr[#to_close_winnr + 1] = winnr
      end
    end
  end
  if not B.file_exists(B.buf_get_name()) then
    local temp = table.remove(to_close_winnr, 1)
    vim.fn.win_gotoid(vim.fn.win_getid(temp))
  end
  for _, winnr in ipairs(to_close_winnr) do
    vim.api.nvim_win_close(vim.fn.win_getid(winnr), false)
  end
end

function M.split_all_other_proj_buffer()
  vim.cmd 'tabo'
  M.close_except_fts()
  if #vim.tbl_keys(M.proj_buffer) > 1 then
    local temp = B.get_proj_root()
    for _, proj in ipairs(vim.tbl_keys(M.proj_buffer)) do
      if proj ~= temp and vim.fn.buflisted(M.proj_buffer[proj]) == 1 then
        vim.cmd 'wincmd ='
        vim.cmd 'wincmd s'
        vim.cmd('b' .. M.proj_buffer[proj])
      end
    end
    vim.cmd 'wincmd ='
  end
end

function M.sel_open()
  local roots = {}
  local cur_proj = B.get_proj_root()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local fname = B.buf_get_name(bufnr)
    if B.is(fname) and B.is_file(fname) then
      local root = B.get_proj_root(fname)
      if cur_proj ~= root then
        roots[root] = {}
      end
      root = vim.fn.trim(root)
      if #root == 0 then
        B.stack_item_uniq(roots[root], fname)
      else
        B.stack_item_uniq(roots[root], string.sub(fname, #root + 2, #fname))
      end
    end
  end
  B.ui_sel(vim.tbl_keys(roots), 'open which proj file', function(root)
    if root then
      if M.proj_buffer[root] and B.is(vim.fn.bufexists(M.proj_buffer[root])) then
        B.cmd('b%s', M.proj_buffer[root])
      else
        local len = #vim.tbl_keys(roots)
        for i = 1, len do
          local fname = ''
          if #root > 0 then
            fname = B.get_file(root, roots[root][len + 1 - i])
          else
            fname = roots[root][len + 1 - i]
          end
          if not B.is_detected_as_bin(fname) then
            B.cmd('e %s', fname)
            break
          end
        end
      end
    end
  end)
  if #vim.tbl_keys(roots) <= 20 then
    vim.fn.timer_start(20, function() vim.cmd [[call feedkeys("\<esc>")]] end)
  end
end

function M.just_split_other_proj_buffer()
  vim.cmd 'tabo'
  M.close_except_fts()
  vim.cmd 'wincmd s'
  M.sel_open()
end

function M.open_other_proj_buffer()
  vim.cmd 'tabo'
  M.close_except_fts()
  M.sel_open()
end

function M.change_around(dir)
  local winid1, bufnr1, winid2, bufnr2
  if B.is_in_tbl(vim.api.nvim_buf_get_option(vim.fn.bufnr(), 'filetype'), M.DoNotCloseFileTypes) then
    return
  end
  winid1 = vim.fn.win_getid()
  bufnr1 = vim.fn.bufnr()
  vim.cmd('wincmd ' .. dir)
  winid2 = vim.fn.win_getid()
  if B.is_in_tbl(vim.api.nvim_buf_get_option(vim.fn.bufnr(), 'filetype'), M.DoNotCloseFileTypes) then
    vim.fn.win_gotoid(winid1)
    return
  end
  if winid1 ~= winid2 then
    bufnr2 = vim.fn.bufnr()
    vim.cmd('b' .. tostring(bufnr1))
    vim.fn.win_gotoid(winid1)
    vim.cmd 'set nowinfixheight'
    vim.cmd 'set nowinfixwidth'
    vim.cmd('b' .. tostring(bufnr2))
    vim.fn.win_gotoid(winid2)
    vim.cmd 'set nowinfixheight'
    vim.cmd 'set nowinfixwidth'
  end
end

function M.go_last_window()
  local winid = vim.fn.win_getid(vim.fn.winnr '$')
  vim.fn.win_gotoid(winid)
end

return M
