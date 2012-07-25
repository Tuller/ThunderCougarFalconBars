--[[
	Classy.lua
		A wrapper for defining classes that inherit from widgets
--]]

local AddonName, Addon = ...

function Addon:NewFrameClass(frameType, parentClass)
	local class = CreateFrame(frameType, nil, nil, 'SecureHandlerBaseTemplate')
	local mt = {__index = class}

	if parentClass then
		class = setmetatable(class, {__index = parentClass})
		
		class.Super = function(methodName, ...)
			local method = parentClass[methodName]
			
			if not method then
				error('Method does not exist: ' .. methodName, 2)
			end
			
			return method(...)
		end
	end

	class.Bind = function(self, obj)
		return setmetatable(obj, mt)
	end

	return class
end