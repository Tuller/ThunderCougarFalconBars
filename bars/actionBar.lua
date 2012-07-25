--[[
	bagBar.lua
		A bar that contains the menu bar bag buttons
--]]

local AddonName, Addon = ...
local ActionBar = Addon:NewFrameClass('Frame', Addon.ButtonBar); Addon.ActionBar = ActionBar

function ActionBar:Create(frameId)
	local bar = ActionBar.Super('Create', self, frameId)
	
	local baseId = (tonumber(frameId) - 1) * 12
	for id = 1, 12 do
		local actionId = baseId + id
		bar:AddButton(Addon.ActionButton:New(actionId))
	end
	
	return bar
end