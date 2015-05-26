local p = require("package")
assert( p.loaders )
assert( p.loaders[1] )

local function none(...) print("OHOH", ...) return nil, "fake loader nothing done" end
assert( p.loaders[1] ~= none)
table.insert(p.loaders, 1, none)
assert( p.loaders[1] == none)

local o = p.loaded.os
p.preload.os = function() return o end
p.loaded.os = nil

p.loaders[1] = nil
if pcall(require, "os") then
	print("supporte package.loaders[1] = nil")
else
	print("ne supporte PAS package.loaders[1] = nil")
end
