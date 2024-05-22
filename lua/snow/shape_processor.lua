local lib = require "snow.lib"

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
    update(env)
  end
  local context = env.engine.context
  context.select_notifier:connect(clear)
  context.commit_notifier:connect(clear)
end

---@param key KeyEvent
---@param env AssistEnv
function processor.func(key, env)
  local input = lib.current(env.engine.context)
  if not input then
    return lib.process_results.kNoop
  end
  if not lib.match(input, "[bpmfdtnlgkhjqxzcsrwyv][aeiou]{3,}") then
    env.engine.context:set_property("shape_input", "")
    return lib.process_results.kNoop
  end
  local context = env.engine.context
  local shape_input = context:get_property("shape_input") or ""
  local keyName = key:repr()
  if keyName == "BackSpace" and shape_input ~= "" then
    shape_input = shape_input:sub(1, -2)
    goto update
  elseif lib.match(keyName, "[aeiou]") then
    shape_input = shape_input .. keyName
    goto update
  else
    return lib.process_results.kNoop
  end
  ::update::
  context:set_property("shape_input", shape_input)
  update(env)
  return lib.process_results.kAccepted
end

return processor
