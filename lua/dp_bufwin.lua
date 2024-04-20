local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

if B.check_plugins {
      -- 'git@github.com:peter-lyr/dp_init',
      'folke/which-key.nvim',
    } then
  return
end

M.proj_buffer = {}

M.max_height_en = nil

function M._get_font_name_size()
  local fontname
  local fontsize
  for k, v in string.gmatch(vim.g.GuiFont, '(.*:h)(%d+)') do
    fontname, fontsize = k, v
  end
  return fontname, tonumber(fontsize)
end

M.normal_fontsize = 9

local _, _fontsize = M._get_font_name_size()

M.lastfontsize = _fontsize

function M.win_equal()
  vim.cmd 'wincmd ='
end

function M.win_go(dir)
  vim.cmd('wincmd ' .. dir)
  if B.is_in_tbl(dir, { 'j', 'k', }) then
    if M.max_height_en then
      if not B.is(vim.o.winfixheight) then
        B.win_max_height()
      end
    end
    local height = vim.api.nvim_win_get_height(0)
    if height - (B.is(vim.o.winbar) and 1 or 0) == 0 then
      vim.api.nvim_win_set_height(0, height + 1)
    end
  end
end

function M.toggle_max_height()
  if M.max_height_en then
    vim.cmd 'wincmd ='
    M.max_height_en = nil
  else
    B.win_max_height()
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
      if not B.is_in_tbl(vim.api.nvim_buf_get_option(bufnr, 'filetype'), DoNotCloseFileTypes) then
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

function M.sel_open(close)
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
    local temp = close and 1 or 0
    if root then
      if M.proj_buffer[root] and B.is(vim.fn.bufexists(M.proj_buffer[root])) then
        B.cmd('b%s', M.proj_buffer[root])
        temp = temp + 2
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
            temp = temp + 2
            break
          end
        end
      end
    end
    if temp == 1 then
      vim.cmd 'close'
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
  M.sel_open(1)
end

function M.open_other_proj_buffer()
  vim.cmd 'tabo'
  M.close_except_fts()
  M.sel_open()
end

function M.change_around(dir)
  local winid1, bufnr1, winid2, bufnr2
  if B.is_in_tbl(vim.api.nvim_buf_get_option(vim.fn.bufnr(), 'filetype'), DoNotCloseFileTypes) then
    return
  end
  winid1 = vim.fn.win_getid()
  bufnr1 = vim.fn.bufnr()
  vim.cmd('wincmd ' .. dir)
  winid2 = vim.fn.win_getid()
  if B.is_in_tbl(vim.api.nvim_buf_get_option(vim.fn.bufnr(), 'filetype'), DoNotCloseFileTypes) then
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

function M._change_font_size(name, size)
  local cmd = 'GuiFont! ' .. name .. size
  local _, __fontsize = M._get_font_name_size()
  if size ~= __fontsize then
    B.set_timeout(100, function() B.notify_info(cmd) end)
  end
  vim.cmd(cmd)
end

function M.fontsize_up()
  local fontname, fontsize = M._get_font_name_size()
  if fontsize < 72 then
    M.lastfontsize = fontsize
    M._change_font_size(fontname, fontsize + 1)
  end
end

function M.fontsize_down()
  local fontname, fontsize = M._get_font_name_size()
  if fontsize > 1 then
    M.lastfontsize = fontsize
    M._change_font_size(fontname, fontsize - 1)
  end
end

function M.fontsize_normal()
  local fontname, fontsize = M._get_font_name_size()
  if B.is(fontsize == M.normal_fontsize) then
    M._change_font_size(fontname, M.lastfontsize)
  else
    M._change_font_size(fontname, M.normal_fontsize)
  end
end

function M.fontsize_min()
  local fontname, _ = M._get_font_name_size()
  M.lastfontsize = 1
  M._change_font_size(fontname, 1)
end

function M.fontsize_frameless() vim.fn['GuiWindowFrameless'](1 - vim.g.GuiWindowFrameless) end

function M.fontsize_fullscreen() vim.fn['GuiWindowFullScreen'](1 - vim.g.GuiWindowFullScreen) end

require 'which-key'.register {
  ['<leader>w'] = { name = 'bufwin', },
  ['<leader>w;'] = { function() M.toggle_max_height() end, 'win: auto max height toggle', mode = { 'n', 'v', }, },
  ['<leader>we'] = { function() M.win_equal() end, 'win: equal', mode = { 'n', 'v', }, },
  ['<leader>wm'] = { function() B.win_max_height() end, 'win: max height', mode = { 'n', 'v', }, },
  ['<leader>wh'] = { function() M.win_go 'h' end, 'win: go left', mode = { 'n', 'v', }, },
  ['<leader>wj'] = { function() M.win_go 'j' end, 'win: go down', mode = { 'n', 'v', }, },
  ['<leader>wk'] = { function() M.win_go 'k' end, 'win: go up', mode = { 'n', 'v', }, },
  ['<leader>wl'] = { function() M.win_go 'l' end, 'win: go right', mode = { 'n', 'v', }, },
  ['<leader>wa'] = { function() M.change_around 'h' end, 'exchange with window: left', mode = { 'n', 'v', }, },
  ['<leader>ws'] = { function() M.change_around 'j' end, 'exchange with window: down', mode = { 'n', 'v', }, },
  ['<leader>ww'] = { function() M.change_around 'k' end, 'exchange with window: up', mode = { 'n', 'v', }, },
  ['<leader>wd'] = { function() M.change_around 'l' end, 'exchange with window: right', mode = { 'n', 'v', }, },
  ['<leader>wz'] = { function() M.go_last_window() end, 'go window: right below', mode = { 'n', 'v', }, },
  ['<leader>wt'] = { '<c-w>t', 'go window: topleft', mode = { 'n', 'v', }, },
  ['<leader>wq'] = { '<c-w>p', 'go window: toggle', mode = { 'n', 'v', }, },
  ['<leader>wn'] = { '<c-w>w', 'go window: next', mode = { 'n', 'v', }, },
  ['<leader>wg'] = { '<c-w>W', 'go window: prev', mode = { 'n', 'v', }, },
  ['<leader>wu'] = { ':<c-u>leftabove new<cr>', 'create new window: up', mode = { 'n', 'v', }, },
  ['<leader>wi'] = { ':<c-u>new<cr>', 'create new window: down', mode = { 'n', 'v', }, },
  ['<leader>wo'] = { ':<c-u>leftabove vnew<cr>', 'create new window: left', mode = { 'n', 'v', }, },
  ['<leader>wp'] = { ':<c-u>vnew<cr>', 'create new window: right', mode = { 'n', 'v', }, },
  ['<leader>wc'] = { '<c-w>H', 'be most window: up', mode = { 'n', 'v', }, },
  ['<leader>wv'] = { '<c-w>J', 'be most window: down', mode = { 'n', 'v', }, },
  ['<leader>wf'] = { '<c-w>K', 'be most window: left', mode = { 'n', 'v', }, },
  ['<leader>wb'] = { '<c-w>L', 'be most window: right', mode = { 'n', 'v', }, },
  ['<leader>w<leader>'] = { name = 'bufwin.more', },
  ['<leader>w<leader>h'] = { '<c-w>v<c-w>h', 'split window: up', mode = { 'n', 'v', }, },
  ['<leader>w<leader>j'] = { '<c-w>s', 'split window: down', mode = { 'n', 'v', }, },
  ['<leader>w<leader>k'] = { '<c-w>s<c-w>k', 'split window: left', mode = { 'n', 'v', }, },
  ['<leader>w<leader>l'] = { '<c-w>v', 'split window: right', mode = { 'n', 'v', }, },
  ['<leader>x'] = { name = 'bufwin.close', },
  ['<leader>xc'] = { function() M.win_close() end, 'win.close:  cur', mode = { 'n', 'v', }, },
  ['<leader>xh'] = { function() M.win_close 'h' end, 'win.close: left', mode = { 'n', 'v', }, },
  ['<leader>xj'] = { function() M.win_close 'j' end, 'win.close: close down', mode = { 'n', 'v', }, },
  ['<leader>xk'] = { function() M.win_close 'k' end, 'win.close : up', mode = { 'n', 'v', }, },
  ['<leader>xl'] = { function() M.win_close 'l' end, 'win.close : right', mode = { 'n', 'v', }, },
  ['<leader>xo'] = { name = 'bufwin.close.other', },
  ['<leader>xoc'] = { function() vim.cmd 'wincmd o' end, 'win.close.other: windows in cur tab ', mode = { 'n', 'v', }, },
  ['<leader>xot'] = { function() vim.cmd 'tabonly' end, 'win.close.other: windows in other tabs ', mode = { 'n', 'v', }, },
  ['<leader>xoa'] = { function() vim.cmd 'tabonly|wincmd o' end, 'win.close.other: all windows ', mode = { 'n', 'v', }, },
  ['<c-/>'] = { name = 'bufwin proj buffer', },
  ['<c-/>a'] = { function() M.split_all_other_proj_buffer() end, 'bufwin proj buffer: split all other proj buffer', mode = { 'n', 'v', }, },
  ['<c-/>j'] = { function() M.just_split_other_proj_buffer() end, 'bufwin proj buffer: just split other proj buffer', mode = { 'n', 'v', }, },
  ['<c-space>'] = { function() M.open_other_proj_buffer() end, 'bufwin proj buffer: open other proj buffer', mode = { 'n', 'v', }, },
  ['<a-h>'] = { function() vim.cmd 'wincmd <' end, 'bufwin font size: width less 1', mode = { 'n', 'v', }, silent = true, },
  ['<a-l>'] = { function() vim.cmd 'wincmd >' end, 'bufwin font size: width more 1', mode = { 'n', 'v', }, silent = true, },
  ['<a-j>'] = { function() vim.cmd 'wincmd -' end, 'bufwin font size: height less 1', mode = { 'n', 'v', }, silent = true, },
  ['<a-k>'] = { function() vim.cmd 'wincmd +' end, 'bufwin font size: height more 1', mode = { 'n', 'v', }, silent = true, },
  ['<a-s-h>'] = { function() vim.cmd '10wincmd <' end, 'bufwin font size: width less 10', mode = { 'n', 'v', }, silent = true, },
  ['<a-s-l>'] = { function() vim.cmd '10wincmd >' end, 'bufwin font size: width more 10', mode = { 'n', 'v', }, silent = true, },
  ['<a-s-j>'] = { function() vim.cmd '10wincmd -' end, 'bufwin font size: height less 10', mode = { 'n', 'v', }, silent = true, },
  ['<a-s-k>'] = { function() vim.cmd '10wincmd +' end, 'bufwin font size: height more 10', mode = { 'n', 'v', }, silent = true, },
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

return M
