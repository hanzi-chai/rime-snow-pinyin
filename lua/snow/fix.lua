-- 固顶过滤器
-- 本过滤器读取用户自定义的固顶短语，将其与当前翻译结果进行匹配，如果匹配成功，则将特定字词固顶到特定位置

local snow = require "snow.snow"

local this = {}

---@class SnowFixedFilterEnv: Env
---@field fixed { string : string[] }

---@param env SnowFixedFilterEnv
function this.init(env)
  ---@type { string : string[] }
  env.fixed = {}
  local path = rime_api.get_user_data_dir() .. ("/%s.fixed.txt"):format(env.engine.schema.schema_id)
  local file = io.open(path, "r")
  if not file then
    return
  end
  for line in file:lines() do
    ---@type string, string
    local code, content = line:match("([^\t]+)\t([^\t]+)")
    if not content or not code then
      goto continue
    end
    local words = {}
    for word in content:gmatch("[^%s]+") do
      table.insert(words, word)
    end
    env.fixed[code] = words
    ::continue::
  end
  file:close()
end

---@param segment Segment
---@param env Env
function this.tags_match(segment, env)
  return segment:has_tag("abc")
end

---@param translation Translation
---@param env SnowFixedFilterEnv
function this.func(translation, env)
  local context = env.engine.context
  -- 取出输入中当前正在翻译的一部分
  local segment = context.composition:toSegmentation():back()
  local input = snow.current(context)
  if not segment or not input then
    return snow.kNoop
  end
  local fixed_phrases = env.fixed[input]
  if not fixed_phrases then
    for candidate in translation:iter() do
      yield(candidate)
    end
    return
  end
  -- 生成固顶候选
  ---@type Candidate[]
  local unknown_candidates = {}
  ---@type { string: Candidate }
  local known_candidates = {}
  local i = 1
  for candidate in translation:iter() do
    local text = candidate.text
    local is_fixed = false
    -- 对于一个新的候选，要么加入已知候选，要么加入未知候选
    for _, phrase in ipairs(fixed_phrases) do
      if text == phrase then
        known_candidates[phrase] = candidate
        is_fixed = true
        break
      end
    end
    if not is_fixed then
      table.insert(unknown_candidates, candidate)
    end
    -- 每看过一个新的候选之后，看看是否找到了新的固顶候选，如果找到了，就输出
    local current = fixed_phrases[i]
    if current and known_candidates[current] then
      local cand = known_candidates[current]
      cand.type = "fixed"
      yield(cand)
      i = i + 1
    end
  end
  -- 输出设为固顶但是没在候选中找到的候选
  -- 因为不知道全码是什么，所以只能做一个 SimpleCandidate
  while fixed_phrases[i] do
    local candidate = Candidate("fixed", segment.start, segment._end, fixed_phrases[i], "")
    candidate.preedit = input
    i = i + 1
    yield(candidate)
  end
  -- 输出没有固顶的候选
  for _, candidate in ipairs(unknown_candidates) do
    yield(candidate)
  end
end

return this
