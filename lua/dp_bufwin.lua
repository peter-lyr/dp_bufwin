local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

if B.check_plugins {
      'git@github.com:peter-lyr/dp_init',
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

function M.temp_map_ey()
  B.temp_map {
    { 'k', function() vim.cmd 'exe "norm 5\\<c-y>"' end,  mode = { 'n', 'v', }, silent = true, desc = '5<c-y>', },
    { 'j', function() vim.cmd 'exe "norm 5\\<c-e>"' end,  mode = { 'n', 'v', }, silent = true, desc = '5<c-e>', },
    { 'y', function() vim.cmd 'exe "norm 10\\<c-y>"' end, mode = { 'n', 'v', }, silent = true, desc = '10<c-y>', },
    { 'e', function() vim.cmd 'exe "norm 10\\<c-e>"' end, mode = { 'n', 'v', }, silent = true, desc = '10<c-e>', },
    { 'u', function() vim.cmd 'exe "norm \\<c-u>"' end,   mode = { 'n', 'v', }, silent = true, desc = '5<c-y>', },
    { 'd', function() vim.cmd 'exe "norm \\<c-d>"' end,   mode = { 'n', 'v', }, silent = true, desc = '5<c-e>', },
  }
end

function M.temp_map_jk()
  B.temp_map {
    { 'k', function() vim.cmd 'exe "norm 5\\<up>"' end,    mode = { 'n', 'v', }, silent = true, desc = '5<up>', },
    { 'j', function() vim.cmd 'exe "norm 5\\<down>"' end,  mode = { 'n', 'v', }, silent = true, desc = '5<down>', },
    { 'y', function() vim.cmd 'exe "norm 10\\<up>"' end,   mode = { 'n', 'v', }, silent = true, desc = '10<up>', },
    { 'e', function() vim.cmd 'exe "norm 10\\<down>"' end, mode = { 'n', 'v', }, silent = true, desc = '10<down>', },
    { 'u', function() vim.cmd 'exe "norm 20\\<up>"' end,   mode = { 'n', 'v', }, silent = true, desc = '20<up>', },
    { 'd', function() vim.cmd 'exe "norm 20\\<down>"' end, mode = { 'n', 'v', }, silent = true, desc = '20<down>', },
  }
end

function M.temp_map_window_size()
  B.temp_map {
    { 'h',       function() vim.cmd 'wincmd <' end,   desc = 'bufwin font size: width less 1',   mode = { 'n', 'v', }, silent = true, },
    { 'l',       function() vim.cmd 'wincmd >' end,   desc = 'bufwin font size: width more 1',   mode = { 'n', 'v', }, silent = true, },
    { 'j',       function() vim.cmd 'wincmd -' end,   desc = 'bufwin font size: height less 1',  mode = { 'n', 'v', }, silent = true, },
    { 'k',       function() vim.cmd 'wincmd +' end,   desc = 'bufwin font size: height more 1',  mode = { 'n', 'v', }, silent = true, },
    { '<left>',  function() vim.cmd '10wincmd <' end, desc = 'bufwin font size: width less 10',  mode = { 'n', 'v', }, silent = true, },
    { '<right>', function() vim.cmd '10wincmd >' end, desc = 'bufwin font size: width more 10',  mode = { 'n', 'v', }, silent = true, },
    { '<down>',  function() vim.cmd '10wincmd -' end, desc = 'bufwin font size: height less 10', mode = { 'n', 'v', }, silent = true, },
    { '<up>',    function() vim.cmd '10wincmd +' end, desc = 'bufwin font size: height more 10', mode = { 'n', 'v', }, silent = true, },
  }
end

function M.temp_map_change_around()
  B.temp_map {
    { 'h', function() M.change_around 'h' end, desc = 'exchange with window: left',  mode = { 'n', 'v', }, },
    { 'j', function() M.change_around 'j' end, desc = 'exchange with window: down',  mode = { 'n', 'v', }, },
    { 'k', function() M.change_around 'k' end, desc = 'exchange with window: up',    mode = { 'n', 'v', }, },
    { 'l', function() M.change_around 'l' end, desc = 'exchange with window: right', mode = { 'n', 'v', }, },
  }
end

function M.temp_map_be_most()
  B.temp_map {
    { 'h', '<c-w>H', desc = 'be most window: up',    mode = { 'n', 'v', }, },
    { 'j', '<c-w>J', desc = 'be most window: down',  mode = { 'n', 'v', }, },
    { 'k', '<c-w>K', desc = 'be most window: left',  mode = { 'n', 'v', }, },
    { 'l', '<c-w>L', desc = 'be most window: right', mode = { 'n', 'v', }, },
  }
end

function M.temp_map_go()
  B.temp_map {
    { 'h', function() M.win_go 'h' end, desc = 'win: go left',  mode = { 'n', 'v', }, },
    { 'j', function() M.win_go 'j' end, desc = 'win: go down',  mode = { 'n', 'v', }, },
    { 'k', function() M.win_go 'k' end, desc = 'win: go up',    mode = { 'n', 'v', }, },
    { 'l', function() M.win_go 'l' end, desc = 'win: go right', mode = { 'n', 'v', }, },
  }
end

function M.temp_map_switch()
  B.temp_map {
    { 't', function() vim.cmd 'wincmd t' end, desc = 'go window: topleft',     mode = { 'n', 'v', }, },
    { 'b', function() M.go_last_window() end, desc = 'go window: right below', mode = { 'n', 'v', }, },
    { 'g', function() vim.cmd 'wincmd b' end, desc = 'go window: toggle',      mode = { 'n', 'v', }, },
    { 'p', function() vim.cmd 'wincmd p' end, desc = 'go window: toggle',      mode = { 'n', 'v', }, },
    { 'n', function() vim.cmd 'wincmd w' end, desc = 'go window: next',        mode = { 'n', 'v', }, },
    { 'm', function() vim.cmd 'wincmd W' end, desc = 'go window: prev',        mode = { 'n', 'v', }, },
  }
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

function M.split_down_proj_buffer()
  vim.cmd 'wincmd s'
  M.sel_open(1)
end

function M.split_up_proj_buffer()
  vim.cmd 'wincmd s'
  vim.cmd 'wincmd k'
  M.sel_open(1)
end

function M.split_right_proj_buffer()
  vim.cmd 'wincmd v'
  M.sel_open(1)
end

function M.split_left_proj_buffer()
  vim.cmd 'wincmd v'
  vim.cmd 'wincmd h'
  M.sel_open(1)
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

function M.split_second_proj_buffer()
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
  ['<leader>ww'] = { name = 'bufwin.temp_map', },
  ['<leader>wwe'] = { function() M.temp_map_ey() end, 'win: temp_map_ey', mode = { 'n', 'v', }, },
  ['<leader>wwj'] = { function() M.temp_map_jk() end, 'win: temp_map_jk', mode = { 'n', 'v', }, },
  ['<leader>wws'] = { function() M.temp_map_window_size() end, 'win: temp_map_window_size', mode = { 'n', 'v', }, },
  ['<leader>wwc'] = { function() M.temp_map_change_around() end, 'win: temp_map_change_around', mode = { 'n', 'v', }, },
  ['<leader>wwb'] = { function() M.temp_map_be_most() end, 'win: temp_map_be_most', mode = { 'n', 'v', }, },
  ['<leader>wwi'] = { function() M.temp_map_switch() end, 'win: temp_map_switch', mode = { 'n', 'v', }, },
  ['<leader>w;'] = { function() M.toggle_max_height() end, 'win: toggle_max_height', mode = { 'n', 'v', }, },
  ['<leader>we'] = { function() M.win_equal() end, 'win: win_equal', mode = { 'n', 'v', }, },
  ['<leader>wm'] = { function() B.win_max_height() end, 'win: win_max_height', mode = { 'n', 'v', }, },
}

require 'which-key'.register {
  ['<leader>wwg'] = { function() M.temp_map_go() end, 'win: temp_map_go', mode = { 'n', 'v', }, },
  ['<leader>wh'] = { function() M.win_go 'h' end, 'win: go left', mode = { 'n', 'v', }, },
  ['<leader>wj'] = { function() M.win_go 'j' end, 'win: go down', mode = { 'n', 'v', }, },
  ['<leader>wk'] = { function() M.win_go 'k' end, 'win: go up', mode = { 'n', 'v', }, },
  ['<leader>wl'] = { function() M.win_go 'l' end, 'win: go right', mode = { 'n', 'v', }, },
}

require 'which-key'.register {
  ['<leader>ws'] = { name = 'bufwin.split', },
  ['<leader>wsh'] = { '<c-w>v<c-w>h', 'split window: up', mode = { 'n', 'v', }, },
  ['<leader>wsj'] = { '<c-w>s', 'split window: down', mode = { 'n', 'v', }, },
  ['<leader>wsk'] = { '<c-w>s<c-w>k', 'split window: left', mode = { 'n', 'v', }, },
  ['<leader>wsl'] = { '<c-w>v', 'split window: right', mode = { 'n', 'v', }, },
  ['<leader>wn'] = { name = 'bufwin.new', },
  ['<leader>wnk'] = { ':<c-u>leftabove new<cr>', 'create new window: up', mode = { 'n', 'v', }, },
  ['<leader>wnj'] = { ':<c-u>new<cr>', 'create new window: down', mode = { 'n', 'v', }, },
  ['<leader>wnh'] = { ':<c-u>leftabove vnew<cr>', 'create new window: left', mode = { 'n', 'v', }, },
  ['<leader>wnl'] = { ':<c-u>vnew<cr>', 'create new window: right', mode = { 'n', 'v', }, },
}

require 'which-key'.register {
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
}

require 'which-key'.register {
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

require 'which-key'.register {
  ['<leader>w<leader>'] = { name = 'bufwin proj buffer', },
  ['<leader>w<leader>a'] = { function() M.split_all_other_proj_buffer() end, 'bufwin proj buffer: split all other proj buffer', mode = { 'n', 'v', }, },
  ['<leader>w<leader>s'] = { function() M.split_second_proj_buffer() end, 'bufwin proj buffer: split second proj buffer', mode = { 'n', 'v', }, },
  ['<leader>w<leader>j'] = { function() M.split_down_proj_buffer() end, 'bufwin proj buffer: split down proj buffer', mode = { 'n', 'v', }, },
  ['<leader>w<leader>k'] = { function() M.split_up_proj_buffer() end, 'bufwin proj buffer: split up proj buffer', mode = { 'n', 'v', }, },
  ['<leader>w<leader>h'] = { function() M.split_left_proj_buffer() end, 'bufwin proj buffer: split left proj buffer', mode = { 'n', 'v', }, },
  ['<leader>w<leader>l'] = { function() M.split_right_proj_buffer() end, 'bufwin proj buffer: split right proj buffer', mode = { 'n', 'v', }, },
  ['<c-space>'] = { function() M.open_other_proj_buffer() end, 'bufwin proj buffer: open other proj buffer', mode = { 'n', 'v', }, },
}

return M
