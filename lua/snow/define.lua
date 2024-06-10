---@meta rime

---@class API
---@field get_rime_version fun(): string
---@field get_shared_data_dir fun(): string
---@field get_user_data_dir fun(): string
---@field get_sync_dir fun(): string
---@field get_distribution_name fun(): string
---@field get_distribution_code_name fun(): string
---@field get_distribution_version fun(): string
---@field get_user_id fun(): string
---@field regex_match fun(input: string, pattern: string): boolean
---@field regex_replace fun(input: string, pattern: string, fmt: string): string
rime_api = {}

---@class Log
---@field info fun(string)
---@field warning fun(string)
---@field error fun(string)
log = {}

---@param cand Candidate
function yield(cand) end

---@param values any[]
---@return Set
function Set(values) end

---@param repr string
---@return KeyEvent
function KeyEvent(repr) end

---@param repr string
---@return KeySequence
function KeySequence(repr) end

---@return Code
function Code() end

---@return DictEntry
function DictEntry() end

---@param file_name string
---@return ReverseDb
function ReverseDb(file_name) end

---@param dict_name string
---@return ReverseLookup
function ReverseLookup(dict_name) end

---@param schema_id string
---@return Schema
function Schema(schema_id) end

---@param str string
---@return ConfigValue
function ConfigValue(str) end

---@param memory Memory
---@param typ string
---@param start integer
---@param _end integer
---@param entry DictEntry
---@return Phrase
function Phrase(memory, typ, start, _end, entry) end

---@param type string 類型標識
---@param start integer 分詞開始
---@param _end integer 分詞結束
---@param text string 候選詞内容
---@param comment string 註解
---@return Candidate
function Candidate(type, start, _end, text, comment) end

---@param engine Engine
---@param schema Schema
---@return Memory
function Memory(engine, schema) end

---@param engine Engine
---@param schema Schema
---@param namespace string
---@return Memory
function Memory(engine, schema, namespace) end

---@param engine Engine
---@return Switcher
function Switcher(engine) end

---@return Projection
function Projection() end

---@class Component
---@field Processor fun(engine: Engine, namespace: string, klass: string): Processor
---@field Translator fun(engine: Engine, namespace: string, klass: string): Translator
---@field Segmentor fun(engine: Engine, namespace: string, klass: string): Segmentor
---@field Filter fun(engine: Engine, namespace: string, klass: string): Filter
Component = {}
