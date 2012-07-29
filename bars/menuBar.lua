--[[
	menuBar.lua
		A bar that contains the main menu bar micro menu buttons
--]]

local AddonName, Addon = ...
local MenuBar = Addon:NewFrameClass('Frame', Addon.ButtonBar)

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


--[[
	Menu Bar Controller
--]]

local MenuBarController = Addon:NewModule('MenuBar', 'AceEvent-3.0', 'AceConsole-3.0')

function MenuBarController:OnEnable()
	self.bar = MenuBar:New{
		default = {
			enable = true,
			show = true,
			alpha = 1,
			scale = 1,
			point = 'BOTTOMRIGHT;-200;0',
			anchor = false,
			columns = 12,
			padding = 0,
			spacing = 0,
			padW = 0,
			padH = 0,
		},		
	}
end

function MenuBarController:OnDisable()

end