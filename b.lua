
local PRINT = print

local stackB = {
require = function(...)
	PRINT("B: require", ...)
	return "required"
end,
print = function(...)
	PRINT("B:", ...)
end,
}
return stackB
