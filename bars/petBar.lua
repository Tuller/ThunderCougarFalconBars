--[[
	petBar.lua
		A bar that contains the pet action buttons
--]]

local TCFB = select(2, ...)
local PetBar = LibStub('Classy-1.0'):New('Frame', TCFB.ButtonBar)
TCFB.PetBar = PetBar

function PetBar:New(settings)
	return TCFB.ButtonBar['New'](self, 'pet', settings)
end

function PetBar:Create(frameId)
	local bar = TCFB.ButtonBar['Create'](self, frameId)
		
	--create proxy frame so that we can hide pet buttons independent of hiding the main frame
	bar:SetFrameRef('buttonFrame', CreateFrame('Frame', nil, bar, 'SecureHandlerStateTemplate'))
	RegisterStateDriver(bar, 'pet', '[@pet,exists,nobonusbar:5]show;hide')
	
	bar:SetAttribute('_onstate-pet', [[
		local buttonFrame = self:GetFrameRef('buttonFrame')
		local petShown = newstate == 'show'
		
		if petShown then
			buttonFrame:Show()
		else
			buttonFrame:Hide()
		end
	]])
	
	bar:Execute([[
		SPACING_OFFSET = 4
		PADW_OFFSET = 2
		PADH_OFFSET = 2
	]])
	
	--load buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		bar:AddButton(_G['PetActionButton' .. i])
	end
	
	return bar
end