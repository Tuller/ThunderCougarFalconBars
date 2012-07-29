--[[
	bagBar.lua
		A bar that contains the menu bar bag buttons
--]]

local AddonName, Addon = ...
local ActionBar = Addon:NewFrameClass('Frame', Addon.ButtonBar)

function ActionBar:Create(frameId)
	local bar = ActionBar.Super('Create', self, frameId)
	
	local baseId = (tonumber(frameId) - 1) * 12
	for id = 1, 12 do
		local actionId = baseId + id
		bar:AddButton(Addon.ActionButton:New(actionId))
	end
	
	return bar
end


--[[
	Action Bar Controller
--]]

local ActionBarController = Addon:NewModule('ActionBar', 'AceEvent-3.0', 'AceConsole-3.0')

function ActionBarController:OnEnable()
	for id = 1, 12 do
		ActionBar:New(id, {
			default = {
				enable = true,
				show = true,
				alpha = 1,
				scale = 1,
				point = string.format('BOTTOM;0;%d', 40 * (id - 1)),
				anchor = false,
				columns = 12,
				padding = 0,
				spacing = 0,
				padW = 0,
				padH = 0,
			},		
		})
	end
end

function ActionBarController:OnDisable()
end