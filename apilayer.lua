require("package").preload["compat_env"] = function(...)-- <pack compat_env> --
--[[
  compat_env - see README for details.
  (c) 2012 David Manura.  Licensed under Lua 5.1/5.2 terms (MIT license).
--]]

local M = {_TYPE='module', _NAME='compat_env', _VERSION='0.2.2.20120406'}

local function check_chunk_type(s, mode)
  local nmode = mode or 'bt' 
  local is_binary = s and #s > 0 and s:byte(1) == 27
  if is_binary and not nmode:match'b' then
    return nil, ("attempt to load a binary chunk (mode is '%s')"):format(mode)
  elseif not is_binary and not nmode:match't' then
    return nil, ("attempt to load a text chunk (mode is '%s')"):format(mode)
  end
  return true
end

local IS_52_LOAD = pcall(load, '')
if IS_52_LOAD then
  M.load     = _G.load
  M.loadfile = _G.loadfile
else
  -- 5.2 style `load` implemented in 5.1
  function M.load(ld, source, mode, env)
    local f
    if type(ld) == 'string' then
      local s = ld
      local ok, err = check_chunk_type(s, mode)
      if not ok then return ok, err end
      local err; f, err = loadstring(s, source)
      if not f then return f, err end
    elseif type(ld) == 'function' then
      local ld2 = ld
      if (mode or 'bt') ~= 'bt' then
        local first = ld()
        local ok, err = check_chunk_type(first, mode)
        if not ok then return ok, err end
        ld2 = function()
          if first then
            local chunk=first; first=nil; return chunk
          else return ld() end
        end
      end
      local err; f, err = load(ld2, source); if not f then return f, err end
    else
      error(("bad argument #1 to 'load' (function expected, got %s)")
            :format(type(ld)), 2)
    end
    if env then setfenv(f, env) end
    return f
  end

  -- 5.2 style `loadfile` implemented in 5.1
  function M.loadfile(filename, mode, env)
    if (mode or 'bt') ~= 'bt' then
      local ioerr
      local fh, err = io.open(filename, 'rb'); if not fh then return fh,err end
      local function ld()
        local chunk; chunk,ioerr = fh:read(4096); return chunk
      end
      local f, err = M.load(ld, filename and '@'..filename, mode, env)
      fh:close()
      if not f then return f, err end
      if ioerr then return nil, ioerr end
      return f
    else
      local f, err = loadfile(filename); if not f then return f, err end
      if env then setfenv(f, env) end
      return f
    end
  end
end

if _G.setfenv then -- Lua 5.1
  M.setfenv = _G.setfenv
  M.getfenv = _G.getfenv
else -- >= Lua 5.2
  -- helper function for `getfenv`/`setfenv`
  local function envlookup(f)
    local name, val
    local up = 0
    local unknown
    repeat
      up=up+1; name, val = debug.getupvalue(f, up)
      if name == '' then unknown = true end
    until name == '_ENV' or name == nil
    if name ~= '_ENV' then
      up = nil
      if unknown then
        error("upvalues not readable in Lua 5.2 when debug info missing", 3)
      end
    end
    return (name == '_ENV') and up, val, unknown
  end

  -- helper function for `getfenv`/`setfenv`
  local function envhelper(f, name)
    if type(f) == 'number' then
      if f < 0 then
        error(("bad argument #1 to '%s' (level must be non-negative)")
              :format(name), 3)
      elseif f < 1 then
        error("thread environments unsupported in Lua 5.2", 3) --[*]
      end
      f = debug.getinfo(f+2, 'f').func
    elseif type(f) ~= 'function' then
      error(("bad argument #1 to '%s' (number expected, got %s)")
            :format(type(name, f)), 2)
    end
    return f
  end
  -- [*] might simulate with table keyed by coroutine.running()
  
  -- 5.1 style `setfenv` implemented in 5.2
  function M.setfenv(f, t)
    local f = envhelper(f, 'setfenv')
    local up, val, unknown = envlookup(f)
    if up then
      debug.upvaluejoin(f, up, function() return up end, 1) --unique upval[*]
      debug.setupvalue(f, up, t)
    else
      local what = debug.getinfo(f, 'S').what
      if what ~= 'Lua' and what ~= 'main' then -- not Lua func
        error("'setfenv' cannot change environment of given object", 2)
      end -- else ignore no _ENV upvalue (warning: incompatible with 5.1)
    end
    return f  -- invariant: original f ~= 0
  end
  -- [*] http://lua-users.org/lists/lua-l/2010-06/msg00313.html

  -- 5.1 style `getfenv` implemented in 5.2
  function M.getfenv(f)
    if f == 0 or f == nil then return _G end -- simulated behavior
    local f = envhelper(f, 'setfenv')
    local up, val = envlookup(f)
    if not up then return _G end -- simulated behavior [**]
    return val
  end
  -- [**] possible reasons: no _ENV upvalue, C function
end


return M
end;
require("package").preload["restricted"] = function(...)-- <pack restricted> --

local assert = assert
local type = assert(type)
local load = assert(load)
local error = assert(error)
local ipairs = ipairs
--local format = ("").format

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
	error( ("module `%s' not found"):format(name), 3)
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
--			error( ("loop or previous error loading module '%s'"):format(modname), 2)
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

-- TODO: set the usual package.path,cpath,config ?

local function _load(code, _srv, _mode, env)
	if type(env)== "table" and type(code)=="string" then
		return load(code, nil, nil, env)
	end
	return nil, "denied"
end

local e = {}
e._G = e

if opts.load and not opts.no_load then
	e.load = _load
end -- /load

if opts.require and not opts.no_require then
	e.require = _require
end

e.setmetatable = setmetatable
e.getmetatable = getmetatable
e.error = error
e.assert = assert
e.type = type
e.ipairs = ipairs
e.pcall = pcall

-- TODO: stuff to pass handler to catch uplevel_loader withtout needs to return it
if opts.loaders_pass then
	opts.loaders_pass(uplevel_loader)
end

	return e
end -- /NEW

local _M = {}
_M.new = new
return _M
end;
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
