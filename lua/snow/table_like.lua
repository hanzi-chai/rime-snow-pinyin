-- 模拟码表翻译器
-- 适用于：冰雪三拼

local snow = require "snow.snow"

---@class ProxyTranslatorEnv: Env
---@field translator Translator

local t12 = {}

---@param env ProxyTranslatorEnv
function t12.init(env)
  env.translator = Component.Translator(env.engine, "translator", "script_translator")
end

---@param input string
---@param segment Segment
---@param env ProxyTranslatorEnv
function t12.func(input, segment, env)
  -- 一字词
  if rime_api.regex_match(input, "[bpmfdtnlgkhjqxzcsrywviu][a-z]?[aeo;]?") then
    local translation = env.translator:query(input, segment)
    for candidate in translation:iter() do
      yield(snow.prepare(candidate, input, true))
    end
  end
  -- 二字词
  if rime_api.regex_match(input, "[bpmfdtnlgkhjqxzcsrywviu][a-z][bpmfdtnlgkhjqxzcsrywviu]([a-z][aeo;]{0,2})?") then
    local proxy = ("%s %s"):format(input:sub(1, 2), input:sub(3))
    if input:len() == 6 then
      proxy = ("%s%s %s"):format(input:sub(1, 2), input:sub(-1, -1), input:sub(3, -2))
    end
    local translation = env.translator:query(proxy, segment)
    for candidate in translation:iter() do
      if utf8.len(candidate.text) <= 2 then
        yield(snow.prepare(candidate, proxy, true))
      end
    end
  end
end

local t3 = {}

---@param env ProxyTranslatorEnv
function t3.init(env)
  env.translator = Component.Translator(env.engine, "translator", "script_translator")
end

---@param input string
---@param segment Segment
---@param env ProxyTranslatorEnv
function t3.func(input, segment, env)
  -- 三字词
  if rime_api.regex_match(input, "[bpmfdtnlgkhjqxzcsrywviu]{3}([a-z][aeo;]{0,2})?") then
    local proxy = ("%s %s %s"):format(input:sub(1, 1), input:sub(2, 2), input:sub(3))
    if input:len() == 6 then
      proxy = ("%s?%s %s %s"):format(input:sub(1, 1), input:sub(-1, -1), input:sub(2, 2), input:sub(3, -2))
    end
    local translation = env.translator:query(proxy, segment)
    for candidate in translation:iter() do
      if utf8.len(candidate.text) == 3 then
        yield(snow.prepare(candidate, proxy, false))
      end
    end
  end
end

local t4 = {}

---@param env ProxyTranslatorEnv
function t4.init(env)
  env.translator = Component.Translator(env.engine, "translator", "script_translator")
end

---@param input string
---@param segment Segment
---@param env ProxyTranslatorEnv
function t4.func(input, segment, env)
  -- 多字词
  if rime_api.regex_match(input, "[bpmfdtnlgkhjqxzcsrywviu]{4,}[aeo;]{0,2}") then
    local proxy = input:gsub("[aeo;]", ""):gsub(".", "%1 "):sub(1, -2)
    local buma = input:gsub("[bpmfdtnlgkhjqxzcsrywviu]", "")
    if buma:len() == 1 then
      proxy = ("%s?%s"):format(proxy, buma)
    elseif buma:len() == 2 then
      proxy = ("%s?%s%s?%s"):format(
        proxy:sub(1, 1),
        buma:sub(2),
        proxy:sub(2),
        buma:sub(1, 1)
      )
    end
    local translation = env.translator:query(proxy, segment)
    for candidate in translation:iter() do
      yield(snow.prepare(candidate, proxy, false))
    end
  end
end

return {
  t12 = t12,
  t3 = t3,
  t4 = t4,
}
