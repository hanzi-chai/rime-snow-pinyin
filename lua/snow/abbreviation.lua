-- 略码处理器

local rime = require "snow.lib"

local this = {}

---@param env Env
function this.init(env)
end

local lookup = {
  ["D"] = "的",
  ["L"] = "了",
  ["B"] = "不",
  ["F"] = "一",
  ["R"] = "啊",
  ["U"] = "呀",
}

function utf8.sub(s,i,j)
  i = i or 1
  j = j or -1
  if i<1 or j<1 then
     local n = utf8.len(s)
     if not n then return nil end
     if i<0 then i = n+1+i end
     if j<0 then j = n+1+j end
     if i<0 then i = 1 elseif i>n then i = n end
     if j<0 then j = 1 elseif j>n then j = n end
  end
  if j<i then return "" end
  i = utf8.offset(s,i)
  j = utf8.offset(s,j+1)
  if i and j then return s:sub(i,j-1)
     elseif i then return s:sub(i)
     else return ""
  end
end

---@param key_event KeyEvent
---@param env PoppingEnv
function this.func(key_event, env)
  local context = env.engine.context
  local selection = context:get_selected_candidate()
  if not selection then
    return rime.process_results.kNoop
  end
  local length = utf8.len(selection.text)
  if key_event:release() or key_event:alt() or key_event:ctrl() or key_event:caps() then
    return rime.process_results.kNoop
  end
  local incoming = utf8.char(key_event.keycode)
  if incoming == '[' and length == 1 then -- 重复一字词
    context:confirm_current_selection()
    context:commit()
    env.engine:commit_text(selection.text)
  elseif lookup[incoming] ~= nil then -- 重复并插入
    context:confirm_current_selection()
    context:commit()
    env.engine:commit_text(lookup[incoming])
    env.engine:commit_text(selection.text)
  elseif incoming == 'E' or incoming == 'I' then -- 重复词的首字或末字
    if incoming == 'E' then
      env.engine:commit_text(utf8.sub(selection.text, 1, 1))
    end
    context:confirm_current_selection()
    context:commit()
    if incoming == 'I' then
      env.engine:commit_text(utf8.sub(selection.text, -1, -1))
    end
  elseif incoming == 'A' then -- 重复多字词
    context:confirm_current_selection()
    context:commit()
    env.engine:commit_text(selection.text)
  elseif incoming == 'O' and length == 2 then -- 叠词重复二字词
    env.engine:commit_text(utf8.sub(selection.text, 1, 1))
    context:confirm_current_selection()
    context:commit()
    env.engine:commit_text(utf8.sub(selection.text, -1, -1))
  elseif incoming == 'W' then -- Ａ着Ａ着
    context:confirm_current_selection()
    context:commit()
    env.engine:commit_text('着' .. selection.text .. '着')
  elseif incoming == 'Q' then -- Ａ来Ａ去
    context:confirm_current_selection()
    context:commit()
    env.engine:commit_text('来' .. selection.text .. '去')
  else
    return rime.process_results.kNoop
  end
  return rime.process_results.kAccepted
end

return this
