--[[
	menuBar.lua
		A bar that contains the main menu bar micro menu buttons
--]]

local TCFB = select(2, ...)
local MenuBar = LibStub('Classy-1.0'):New('Frame', TCFB.ButtonBar)
TCFB.MenuBar = MenuBar

function MenuBar:New(settings)
	return TCFB.ButtonBar['New'](self, 'menu', settings)
end

function MenuBar:Create(frameId)
	local bar = TCFB.ButtonBar['Create'](self, frameId)
	
	bar:Execute([[ 
		SPACING_OFFSET = -2 
		HEIGHT_OFFSET = 22 
	]])
	
	local loadButtons = function(bar, ...)
		for i = 1, select('#', ...) do
			local b = select(i, ...)
			local name = b:GetName()
			if name and name:match('(%w+)MicroButton$') then
				bar:AddButton(b)
			end
		end
	end
	loadButtons(bar, _G['MainMenuBarArtFrame']:GetChildren())
	
	return bar
end