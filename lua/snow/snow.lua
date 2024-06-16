local snow = {
  kRejected = 0,
  kAccepted = 1,
  kNoop = 2,
  kVoid = "kVoid",
  kGuess = "kGuess",
  kSelected = "kSelected",
  kConfirmed = "kConfirmed",
  kNull = "kNull",     -- 空節點
  kScalar = "kScalar", -- 純數據節點
  kList = "kList",     -- 列表節點
  kMap = "kMap",       -- 字典節點
  kShift = 0x1,
  kLock = 0x2,
  kControl = 0x4,
  kAlt = 0x8,
}

--- 取出输入中当前正在翻译的一部分
---@param context Context
function snow.current(context)
  local segment = context.composition:toSegmentation():back()
  if not segment then
    return nil
  end
  return context.input:sub(segment.start + 1, segment._end)
end

---格式化 Info 日志
---@param format string|number
function snow.infof(format, ...)
  log.info(string.format(format, ...))
end

---格式化 Warn 日志
---@param format string|number
function snow.warnf(format, ...)
  log.warning(string.format(format, ...))
end

---格式化 Error 日志
---@param format string|number
function snow.errorf(format, ...)
  log.error(string.format(format, ...))
end

---@param s string
---@param i number
---@param j number
function snow.sub(s, i, j)
  i = i or 1
  j = j or -1
  if i < 1 or j < 1 then
    local n = utf8.len(s)
    if not n then return "" end
    if i < 0 then i = n + 1 + i end
    if j < 0 then j = n + 1 + j end
    if i < 0 then i = 1 elseif i > n then i = n end
    if j < 0 then j = 1 elseif j > n then j = n end
  end
  if j < i then return "" end
  i = utf8.offset(s, i)
  j = utf8.offset(s, j + 1)
  if i and j then
    return s:sub(i, j - 1)
  elseif i then
    return s:sub(i)
  else
    return ""
  end
end

return snow
