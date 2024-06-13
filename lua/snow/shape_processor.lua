local snow = require "snow.snow"

---@param env Env
local function update(env)
  local composition = env.engine.context.composition
  if composition:empty() then
    return
  end
  local segment = composition:back()
  segment.prompt = segment.prompt .. ": " .. (env.engine.context:get_property("shape_input") or "")
  env.engine.context:refresh_non_confirmed_composition()
end

local processor = {}

---@param env Env
function processor.init(env)
  local function clear()
    env.engine.context:set_property("shape_input", "")
    env.engine.context:set_property("shape_status", "")
    update(env)
  end
  local context = env.engine.context
  context.select_notifier:connect(clear)
  context.commit_notifier:connect(clear)
end

---@param key KeyEvent
---@param env AssistEnv
function processor.func(key, env)
  local input = snow.current(env.engine.context)
  if not input or input:len() == 0 then
    env.engine.context:set_property("shape_input", "")
    return snow.kNoop
  end
  -- 追加编码
  local context = env.engine.context
  local shape_input = context:get_property("shape_input")
  local keyName = key:repr()
  if keyName == "1" and rime_api.regex_match(input, "[bpmfdtnlgkhjqxzcsrywv][aeiou]{0,3}") then
    shape_input = "1"
    goto update
  elseif keyName == "BackSpace" and shape_input ~= "" then
    shape_input = shape_input:sub(1, -2)
    goto update
  elseif shape_input == "1" and rime_api.regex_match(keyName, "[a-z]") then
    shape_input = shape_input .. keyName
    goto update
  elseif (rime_api.regex_match(input, "[bpmfdtnlgkhjqxzcsrywv][aeiou]{3}") or shape_input:len() > 0) and rime_api.regex_match(keyName, "[aeiou]") then
    shape_input = shape_input .. keyName
    goto update
  else
    return snow.kNoop
  end
  ::update::
  context:set_property("shape_input", shape_input)
  update(env)
  return snow.kAccepted
end

return processor
