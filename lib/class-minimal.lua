
--[[
Copyright (c) 2009-2011 Bart van Strien

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]--

-- Original from barbes
-- Changed by TsT

local setmetatable = setmetatable
local getmetatable = getmetatable

local class_mt = {}
function class_mt:__index(key)
    return self.__baseclass[key]
end

local class = setmetatable({ __baseclass = {} }, class_mt)

local function _class(self, name, t, parent)
	parent = parent or class
	t = t or {}
	t.__baseclass = parent
	return setmetatable(t, getmetatable(parent))
end

local function _instance(self, class, ...)
	local c = {}
	c.__baseclass = self
	setmetatable(c, getmetatable(self))
	if c.init then
		c:init(...)
	end
	return c
end

return {class = _class, instance = _instance}
