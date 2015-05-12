local assert = assert
local setmetatable = assert(setmetatable)
local getmetatable = assert(getmetatable)

local compat_env = require("compat_env")
local load = assert(compat_env.load)

local function new_env()
	local r = require("restricted")
	local env = r.new({intercept_loaders=false, load=true, require=true})

	local package = env.require("package")
	if package.loaded._G == nil then
		package.loaded._G = env
	end
	assert(package.loaded._G == env)

	env._G = env -- emul: _G._G == _G

	local function do_nothing(t, k, v) end
	local mt = { __index=env, __newindex=do_nothing, metatable="locked", } -- lock it ?

	return setmetatable({}, mt), env, mt
end

local function precache_in(what, env)
	assert(type(what)=="table")
	for k,v in pairs(what) do
		if env[k] == nil then
			env[k] = v
		end
	end
end

--setmetatable(envAB, {__index = _G})
--setmetatable(envBA, {__index = _G})

local _M = {}
_M.new_env = assert(new_env)
_M.precache_in = assert(precache_in)
_M.load = load
--_M.loadfile = loadfile

return _M
