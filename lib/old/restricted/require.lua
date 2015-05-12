
local assert = assert
local type = assert(type)
local load = assert(load)
local error = assert(error)
local ipairs = ipairs
--local format = ("").format

local function new() -- NEW

-- A way to intercept the loaders's call
local uplevel_loader = {Lua=nil, C=nil, Croot=nil}

-- ###########


local package = {}

local _LOADED = {package = package} -- register the package itself as already loaded

package.loaded = _LOADED -- expose the table

local _PRELOAD = {}
package.preload = _PRELOAD -- expose the table

--
-- check whether library is already loaded
--
local function loader_preload(name)
	assert (type(name)=="string", ("bad argument #1 to `require' (string expected, got %s)"):format(type(name)) )
	assert (type(_PRELOAD)=="table", "`package.preload' must be a table")
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
	for i, loader in ipairs(loaders) do
		local f = loader(name)
		if f then
			return f
		end
	end
	error( ("module `%s' not found"):format(name) )
end

-- sentinel
local sentinel = {}
-- TODO: remove the use of sentinel !!!

-- 
-- new require
-- 
local function _require(modname)
	assert(type(modname) == "string", ("bad argument #1 to `require' (string expected, got %s)"):format(type(name)))
	local p = _LOADED[modname]
	if p then -- is it there?
--		if p == sentinel then
--			error( ("loop or previous error loading module '%s'"):format(modname) )
--		end
		return p -- package is already loaded
	end
	local init = _internal_load(modname, _LOADERS)
--	_LOADED[modname] = sentinel
	local res = init(modname)
	if res then
		_LOADED[modname] = res
	end
--	if _LOADED[modname] == sentinel then
--		_LOADED[modname] = true
--	end
	return _LOADED[modname]
end

-- TODO: set the usual package.path cpath sep ?

	return _require, uplevel_loader
end -- /NEW

local _M = {}
_M.new = new -- return require, uplevel_loader, ...
return _M
