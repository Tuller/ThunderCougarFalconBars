local TCFB = select(2, ...)
local PetBar = LibStub('Classy-1.0'):New('Frame', TCFB.Bar)
TCFB.PetBar = PetBar

local BAR_ATTRIBUTES = {
	'enable',
	'show',
	'scale',
	'alpha',
	'point',
	'anchor',
	'columns',
	'spacing',
	'padW',
	'padH'
}

function PetBar:New(settings)
	local f = self:super('New', 'pet', settings)
	return f
end

function PetBar:Create(frameId)
	local bar = self:super('Create', frameId)
	
	--proxy frame of justice
	bar:SetFrameRef('buttonFrame', CreateFrame('Frame', nil, bar, 'SecureHandlerStateTemplate'))
	RegisterStateDriver(bar, 'pet', '[@pet,exists,nobonusbar:5]show;hide')
	
	bar:SetAttribute('myAttributes', table.concat(BAR_ATTRIBUTES, ','))
	
	bar:SetAttribute('_onstate-main', [[
		self:RunAttribute('lodas', string.split(',', self:GetAttribute('myAttributes')))
		self:RunAttribute('layout')
	]])
	
	bar:SetAttribute('_onstate-numForms', [[
		needsLayout = true
	]])
	
	bar:SetAttribute('_onstate-columns', [[
		needsLayout = true
	]])
	
	bar:SetAttribute('_onstate-spacing', [[
		needsLayout = true
	]])
	
	bar:SetAttribute('_onstate-padW', [[
		needsLayout = true
	]])
	
	bar:SetAttribute('_onstate-padH', [[
		needsLayout = true
	]])
	
	bar:SetAttribute('_onstate-pet', [[
		local buttonFrame = self:GetFrameRef('buttonFrame')
		local petShown = newstate == 'show'
		
		if petShown then
			buttonFrame:Show()
		else
			buttonFrame:Hide()
		end
	]])
	
	bar:Execute([[ SPACING_OFFSET = 4; PADDING_OFFSET = 2 ]])
	
	bar:SetAttribute('layout', [[
		if not(myButtons and needsLayout) then return end

		local numButtons = #myButtons
		local cols = min(self:GetAttribute('state-columns'), numButtons)
		local rows = ceil(numButtons / cols)
		local spacing = self:GetAttribute('state-spacing') + SPACING_OFFSET
		local pW = self:GetAttribute('state-padW') + PADDING_OFFSET 
		local pH = self:GetAttribute('state-padH') + PADDING_OFFSET

		local b = myButtons[1]
		local w = b:GetWidth() + spacing
		local h = b:GetHeight() + spacing
		
		for i = 1, numButtons do
			local b = myButtons[i]
			local col = (i-1) % cols
			local row = ceil(i / cols) - 1
			
			b:ClearAllPoints()
			b:SetPoint('TOPLEFT', self, 'TOPLEFT', w*col + pW, -(h*row + pH))
			b:Show()
		end

		self:SetWidth(max(w*cols - spacing + pW*2, 8))
		self:SetHeight(max(h*rows - spacing + pH*2, 8))
		
		needsLayout = nil
	]])
	
	--add button method
	bar:SetAttribute('addButton', [[
		local button = self:GetFrameRef('addButton')		
		if button then
			myButtons = myButtons or table.new()
			table.insert(myButtons, button)
			button:SetParent(self:GetFrameRef('buttonFrame'))
		end
	]])
	
	--load buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		bar:SetFrameRef('addButton', _G['PetActionButton' .. i])
		bar:Execute([[ self:RunAttribute('addButton') ]])
	end
	
	return bar
end