--[[
	rollBar
		A dominos frame for rolling on items when in a party
--]]


--[[ Module Stuff ]]--

local TCFB = select(2, ...)
local RollBar = LibStub('Classy-1.0'):New('Frame', TCFB.ButtonBar); TCFB.RollBar = RollBar


--[[ Roll Bar Object ]]--

function RollBar:New(settings)
	return TCFB.ButtonBar['New'](self, 'roll', settings)
end


function RollBar:Create(frameId)
	UIPARENT_MANAGED_FRAME_POSITIONS['GroupLootFrame1'] = nil
	
	local bar = TCFB.ButtonBar['Create'](self, frameId)

	for i = 0, NUM_GROUP_LOOT_FRAMES - 1 do
		local lootFrame = _G[string.format('GroupLootFrame%d', (NUM_GROUP_LOOT_FRAMES - i))]
		bar:AddButton(bar:SecureWrap(lootFrame))
	end
	
	return bar
end