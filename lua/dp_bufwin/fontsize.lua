local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

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

return M
