
local assert = assert
local type = assert(type)
local load = assert(load)
local error = assert(error)
--local ipairs = ipairs
local format = assert( ("").format )
local getmetatable = assert( getmetatable )

local classcommon = require("class-minimal")
local class, instance = assert(classcommon.class), assert(classcommon.instance)

local truc = class("truc")
assert(type(truc) == "table")


--[[
if type(tostring) == "function" then
	assert( type(getmetatable(truc)) == "table")
	local mt = getmetatable(truc)
	local truc_txt = tostring(truc)
	function mt:__tostring()
		return "instance de truc "..truc_txt
	end
end
]]--
local _M = {}

return setmetatable(_M, {__call = function(_, ...) return instance(truc, ...) end})


--[==[
local function new(opts) -- NEW

-- A way to intercept the loaders's call
local uplevel_loader = {Lua=nil, C=nil, Croot=nil}

local package = {}

local _LOADED = {package = package} -- register the package itself as already loaded
package.loaded = _LOADED -- expose the table

local _PRELOAD = {}
package.preload = _PRELOAD -- expose the table

--
-- check whether library is already loaded
--
local function loader_preload(name)
	assert(type(name)=="string", format("bad argument #1 to `require' (string expected, got %s)", type(name)))
	assert(type(_PRELOAD)=="table", "`package.preload' must be a table")
	return _PRELOAD[name]
end

--
-- Lua library loader
--
local function loader_Lua(name)
	return uplevel_loader and uplevel_loader.Lua and uplevel_loader.Lua(name)
end

--
-- C library loader
--
local function loader_C(name)
	return uplevel_loader and uplevel_loader.Lua and uplevel_loader.C(name)
end

local function loader_Croot(name)
	return uplevel_loader and uplevel_loader.Lua and uplevel_loader.Croot(name)
end



-- create `loaders' table
local _LOADERS = { loader_preload, loader_Lua, loader_C, loader_Croot, }
package.loaders = _LOADERS -- expose the table

-- 
-- iterate over available loaders
-- 
local function _internal_load(name, loaders)
	-- iterate over available loaders
	assert( type(loaders)=="table", "`package.loaders' must be a table")
	--for i, loader in ipairs(loaders) do
	for i = 1, #loaders, 1 do local loader = loaders[i]
		local f = loader(name)
		if f then
			return f
		end
	end
	-- TODO: missingmod hook here

	error( ("module `%s' not found"):format(name), 3)
end

-- 
-- new require
-- 
local function _require(modname)
	assert(type(modname) == "string", ("bad argument #1 to `require' (string expected, got %s)"):format(type(name)))

	-- TODO: require hook here

	local p = _LOADED[modname]
	if p then -- is it there?
		return p -- package is already loaded
	end
	local init = _internal_load(modname, _LOADERS)
	local res = init(modname)
	if res then
		_LOADED[modname] = res
	end
	return _LOADED[modname]
end

-- TODO: set the usual package.path,cpath,config ?

-- bytecode lua 5.1
--  1b 4c 75 61 51 00 01 04                           |.LuaQ...|
-- bytecode lua 5.2
--  1b 4c 75 61 52 00 01 04                           |.LuaR...|
-- bytecode luajit http://wiki.luajit.org/Bytecode-2.0#LuaJIT-2.0-Bytecode-Dump-Format
--  1b 4c 4a 01 02 14 00 00                           |.LJ.....|
-- common header pattern start by :
--  1b 4c (in hexa) or 27 76 (in dec)

local function bytecodefound(code)
	local bytecodeheader = format("\27\76")
	-- search at the beginning
	if bytecodeheader == code:sub(1,2) then
		return true
	end
	-- search everywhere
	if code:find(bytecodeheader, nil, true) then
		return true
	end
	return false
end

-- problem: with specific BOM (endianess?) it should be possible to invert the order and bypass the check ...

local function _load(code, _srv, _mode, env)
	-- load() should never raise error
	if type(env)~= "table" then
		return nil, "env must be a table"
	end
	if type(code)~="string" then
		return nil, "code must be a string"
	end
	if _mode ~= nil and _mode ~= "t" then
		return nil, "mode must be text only."
	end
	if bytecodefound(code) then
		return nil, "bytecode header detected. bytecode not allowed"
	end
	return load(code, nil, "t", env)
end

local _V = {}
_V._G = _V

if opts.load and not opts.no_load then
	e.load = _load
end

if opts.require and not opts.no_require then
	e.require = _require
end

local str_mt = getmetatable("")
local function _getmetatable(obj)
	local mt = getmetatable(obj)
	if mt == str_mt and type(mt) == "table" then
		return "locked"
	end
	return mt
end

e.setmetatable = setmetatable
e.getmetatable = _getmetatable
e.error = error
e.assert = assert
e.type = type

--e.ipairs = ipairs
--e.pcall = pcall

-- TODO: stuff to pass handler to catch uplevel_loader withtout needs to return it
if opts.loaders_pass then
	opts.loaders_pass(uplevel_loader)
end

	return e
end -- /NEW

local _M = {}
_M.new = new
return _M
]==]--
