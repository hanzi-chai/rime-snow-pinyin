-- 后置过滤器
-- 本过滤器记录码长较短时已出现在首选的字词，当码长较长时将这些字词后置，以便提高编码的利用效率

local snow = require "snow.snow"

local this = {}

---@class SnowPostponeEnv: Env
---@field known_candidates table<string, number>
---@field disable string

---@param env SnowPostponeEnv
function this.init(env)
  env.known_candidates = {}
  env.disable = env.engine.schema.config:get_string("translator/disable_postpone_pattern") or ""
end

---@param segment Segment
---@param env Env
function this.tags_match(segment, env)
  local context = env.engine.context
  -- 在回补时不刷新
  if context.caret_pos ~= context.input:len() then
    return false
  end
  return context:get_option("popping")
end

---@param translation Translation
---@param env SnowPostponeEnv
function this.func(translation, env)
  local context = env.engine.context
  -- 取出输入中当前正在翻译的一部分
  local input = snow.current(context)
  if not input then
    return
  end
  -- 删除与当前编码长度相等或者更长的已知候选，这些对当前输入无帮助
  for k, v in pairs(env.known_candidates) do
    if v >= input:len() then
      env.known_candidates[k] = nil
    end
  end

  -- 设当前编码长度为 n，则：
  -- 过滤开始前，known_candidates 包含 n-1 项，分别是 1 ~ n-1 长度时对应的首选
  -- 过滤结束后，known_candidates 包含 n 项，分别是 1 ~ n 长度时对应的首选

  -- 用于存放需要后置的候选
  ---@type Candidate[]
  local postponed_candidates = {}
  ---@type Candidate[]
  local temp_candidates = {}

  -- 过滤分为三个阶段：
  -- 1. 找出首选：在所有字数等于音节数的候选中，找出最高频且没有在之前的首选中出现的候选。如果没有这样的候选，就不输出
  -- 2. 输出后置：将出现在之前的首选中的候选按照码长降序输出。例如，有几个候选分别在 2, 3, 5 码出现过，那么按照 5, 3, 2 的顺序输出
  -- 3. 输出剩余候选
  -- 为了避免看两次候选，第 1 和 2 步都只看前 10 个候选，其余的就不看了
  local is_first = true
  local count = 0
  local proper_length = 0
  for candidate in translation:iter() do
    if proper_length == 0 then
      proper_length = utf8.len(candidate.text) or 0
    end
    local text = candidate.text
    -- 如果当前候选词的长度已经小于首选了，那么把之前后置过的候选词重新输出
    -- 例如，输入码为两个音节的时候，先输出正常的二字词，然后再输出之前后置的二字词，最后才是单字
    -- 这样可以保证字数较长的词一定排在前面
    -- 做完这件事情之后，剩下的候选词可以直接输出，不用考虑后置
    if utf8.len(text) < proper_length or count >= 10 then
      table.sort(postponed_candidates, function(a, b)
        return env.known_candidates[a.text] > env.known_candidates[b.text]
      end)
      for _, c in ipairs(postponed_candidates) do
        yield(c)
      end
      postponed_candidates = {}
      for _, c in ipairs(temp_candidates) do
        yield(c)
      end
      temp_candidates = {}
      yield(candidate)
      goto continue
    end
    -- 如果这个候选词已经在首选中出现过，那么后置
    if (env.known_candidates[text] or 1000) < input:len() then
      table.insert(postponed_candidates, candidate)
      goto continue
    end
    -- 否则直接输出
    -- 记录首选
    if is_first then
      if not rime_api.regex_match(input, env.disable) then
        env.known_candidates[text] = input:len()
      end
      is_first = false
      yield(candidate)
    elseif candidate.type == "fixed" then
      yield(candidate)
    else
      table.insert(temp_candidates, candidate)
    end
    count = count + 1
    ::continue::
  end
  table.sort(postponed_candidates, function(a, b)
    return env.known_candidates[a.text] > env.known_candidates[b.text]
  end)
  for _, c in ipairs(postponed_candidates) do
    yield(c)
  end
  for _, c in ipairs(temp_candidates) do
    yield(c)
  end
end

return this
