--[[
	menuBar.lua
		A bar that contains the main menu bar micro menu buttons
--]]

local AddonName, Addon = ...
local MenuBar = Addon:NewFrameClass('Frame', Addon.ButtonBar); Addon.MenuBar = MenuBar

function MenuBar:New(settings)
	return MenuBar.Super('New', self, 'menu', settings)
end

function MenuBar:Create(frameId)
	local bar = MenuBar.Super('Create', self, frameId)
	
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