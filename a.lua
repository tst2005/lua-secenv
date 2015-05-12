
local PRINT = print

local stackA = { tostring = function(...)
	PRINT("A: tostring", ...)
	return tostring(...)
end, print = function(...)
	PRINT("A:", ...)
end,
}

return stackA
