local AddonName, Addon = ...
local Utility = {}; Addon.Utility = Utility

function Utility:ConcatArrays(...)
	local results = {}
	
	for tableIndex = 1, select('#', ...) do
		local t = select(tableIndex, ...)
		
		for i, v in ipairs(t) do 
			table.insert(results, v)
		end
	end
	
	return results;
end