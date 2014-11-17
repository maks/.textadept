--common = require 'common'

ui.tabs = false
textadept.editing.STRIP_TRAILING_SPACES = false
ui.set_theme('dark')

-- Wrap text files automatically
events.connect(events.LEXER_LOADED, function(lexer)
     buffer.wrap_mode = lexer == 'text' and buffer.WRAP_WORD
                                        or buffer.WRAP_NONE
end)

-- custom keys
keys['cg'] = textadept.editing.goto_line
-- see below for window mgmt keychain ....

-- Put the current text selection or word under cursor as initial text in find field
keys.cf = { function ()
    local buffer = buffer
    local text = buffer:get_sel_text()
    if #text == 0 then
        text = buffer:text_range(buffer:word_start_position(buffer.current_pos), buffer:word_end_position(buffer.current_pos))
        text = text:gsub("^%s*(.-)%s*$", "%1")
    end
    ui.find.find_entry_text = text
    ui.find.focus()
end } 



-- from vi mode impl: https://github.com/lammermann/ta-vim/blob/master/init.lua#L105
local function move_to_view(v, direction, ts, left, right, above, under)
    local v = view
    local ts = ts or ui.get_split_table()
    local l = left  or v
    local r = right or v
    local a = above or v
    local u = under or v

    if ts.vertical == nil then
      -- This is just a view
      return false
    elseif ts.vertical == true then
      if ts[1] ~= v then l = ts[1] end
      if ts[2] ~= v then r = ts[2] end
    elseif ts.vertical == false then
      if ts[1] ~= v then a = ts[1] end
      if ts[2] ~= v then u = ts[2] end
    end

    if ts[1] == v or ts[2] == v then
      if direction == "right" then
        while r.vertical ~= nil do
          r = r[1]
        end
        return ui.goto_view(_G._VIEWS[r])
      elseif direction == "left" then
        while l.vertical ~= nil do
          l = l[2]
        end
        return ui.goto_view(_G._VIEWS[l])
      elseif direction == "above" then
        while a.vertical ~= nil do
          a = a[2]
        end
        return ui.goto_view(_G._VIEWS[a])
      elseif direction == "under" then
        while u.vertical ~= nil do
          u = u[1]
        end
        return ui.goto_view(_G._VIEWS[u])
      end
    else
      return move_to_view(v, direction, ts[1], l, r, a, u)
        or move_to_view(v, direction, ts[2], l, r, a, u)
    end
end

-- custom keychain for tmux-style window mgmt
keys['cw'] = {
  ['|'] = {view.split, view, true},
  ['-'] = {view.split, view, false},
  ['c'] = {view.unsplit, view},
  ['k'] = {move_to_view, view, "above"}, 
  ['j'] = {move_to_view, view, "under"},
  ['h'] = {move_to_view, view, "left"}, 
  ['l'] = {move_to_view, view, "right"}, 
}




-- VI MODE
--package.path = "/home/maks/.textadept/textadept-vi/?.lua;" .. package.path
--package.cpath = "/home/maks/.textadept/textadept-vi/?.so;" .. package.cpath
--vi_mode = require 'vi_mode'
--
--
--events.connect(events.INITIALIZED, function()
--  require 'textredux.hijack'
--end)
