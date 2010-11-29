--[[
	bagBar.lua
		A bar that contains the menu bar bag buttons
--]]

local TCFB = select(2, ...)
local ActionBar = LibStub('Classy-1.0'):New('Frame', TCFB.ButtonBar)
TCFB.ActionBar = ActionBar

function ActionBar:Create(frameId)
	local bar = TCFB.ButtonBar['Create'](self, frameId)
	
	local baseId = (tonumber(frameId) - 1) * 12
	for id = 1, 12 do
		local actionId = baseId + id
		bar:AddButton(TCFB.ActionButton:New(actionId))
	end
	
	return bar
end