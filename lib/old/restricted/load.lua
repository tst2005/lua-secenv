
local type = assert(type)
local load = assert(load)
local error = assert(error)

local function _load(code, _srv, _mode, env)
	if type(env)== "table" and type(code)=="string" then
		return load(code, nil, nil, env)
	end
	error("denied", 2)
end

local _M = {}
_M.load = _load
return _M
