local lib = require "snow.lib"

local number_to_letter = {
  ["1"] = "e",
  ["2"] = "i",
  ["3"] = "u",
  ["4"] = "o",
  ["5"] = "a",
}

---@class AssistEnv: Env
---@field strokes table<string, string>

local filter = {}

---@param env AssistEnv
function filter.init(env)
  env.strokes = {}
  local path = lib.api.get_user_data_dir() .. "/lua/snow/strokes.txt"
  local file = io.open(path, "r")
  if not file then
    return
  end
  for line in file:lines() do
    ---@type string, string
    local character, content = line:match("([^\t]+)\t([^\t]+)")
    if not content or not character then
      goto continue
    end
    env.strokes[character] = content:gsub("%d", number_to_letter)
    ::continue::
  end
  file:close()
end

---@param translation Translation
---@param env AssistEnv
function filter.func(translation, env)
  local context = env.engine.context
  local input = context:get_property("shape_input") or ""
  for candidate in translation:iter() do
    local code = env.strokes[candidate.text]
    if not code or code:sub(1, #input) == input then
      candidate.comment = code
      if #input > 0 then
        candidate.preedit = candidate.preedit .. " [" .. input .. "]"
      end
      lib.yield(candidate)
    end
  end
end

---@param segment Segment
---@param env AssistEnv
function filter.tags_match(segment, env)
  local current = lib.current(env.engine.context)
  return current and lib.match(current, "[bpmfdtnlgkhjqxzcsrwyv][aeiou]{3,}")
end

return filter
