
local t = {}
print(getmetatable(t))
setmetatable(t, {__metatable = setmetatable({}, {__metatable=true, __tostring=function() return "locked metatable" end, __type="table"})})
print(getmetatable(t), type(getmetatable(t) ) )
setmetatable(t, nil)
print(getmetatable(t))

