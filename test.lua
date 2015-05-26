
local apilayer = require("apilayer")
local load = assert(apilayer.load) -- load() like 5.2 (compat appplied if nedded)
local new_env = assert(apilayer.new_env)
local precache_in = assert(apilayer.precache_in)

do
	local str = require("string")
	local mt = getmetatable("")
	assert(str == mt.__index)
	mt.__add = function()
		print("debug-str-add: ", _G)
		return "debug"
	end
end

print("_G", _G)
local c = ("a" + "b")


local stackA = require("a")
local stackB = require("b")

local envAB, rawAB = new_env()
precache_in(stackA, rawAB)
precache_in(stackB, rawAB)
do	local env = envAB
	assert(env.print and env.tostring and env.require)
end

local envBA, rawBA = new_env()
precache_in(stackB, rawBA)
precache_in(stackA, rawBA)
do	local env = envBA
	assert(env.print and env.tostring and env.require)
end

local code = [[
print('ok');
print(tostring(123))
--require('req')
print(io)
print("a" + "b")
]]

assert(code)
assert(envAB)
assert(envBA)

--load(code)() -- in _G
print("---------------- AB")
load(code, nil, nil, envAB)() -- in envAB
print("")
print("---------------- BA")
load(code, nil, nil, envBA)() -- in envBA

