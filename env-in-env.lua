
local code = [[
--assert(code)
print(type(data))

local apilayer = data and load(data) or require("apilayer")
local load = assert(apilayer.load) -- load() like 5.2 (compat appplied if nedded)
local new_env = assert(apilayer.new_env)

local newAB, rawAB = new_env()
rawAB.data = data
rawAB.code = code
rawAB.print = print

do
local raw = rawAB
assert( raw.require and raw.require("package") and raw.require("_G") )
raw.require("package").loaded["_V"] = raw.require("_G")
end

print('data', type(data), 'code', type(code));
print('io', io)
return newAB, rawAB
]]

local fd = io.open("apilayer.lua", "r")
local data = fd:read('*all')
fd:close()

local apilayer = require("apilayer")
local load = assert(apilayer.load) -- load() like 5.2 (compat appplied if nedded)
local new_env = assert(apilayer.new_env)


print('in _G:')
local a, b = load(code) -- in _G
print("returns...", a, b)
print("---------------- AB")
load(code, nil, nil, assert(a))() -- in envAB

