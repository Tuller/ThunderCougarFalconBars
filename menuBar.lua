local TCFB = select(2, ...)
local MenuBar = LibStub('Classy-1.0'):New('Frame', TCFB.Bar)
TCFB.MenuBar = MenuBar

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

local MENU_BUTTONS = {}
do
	local loadButtons = function(buttons, ...)
		for i = 1, select('#', ...) do
			local b = select(i, ...)
			local name = b:GetName()
			if name and name:match('(%w+)MicroButton$') then
				table.insert(buttons, b)
			end
		end
	end
	loadButtons(MENU_BUTTONS, _G['MainMenuBarArtFrame']:GetChildren())
end

function MenuBar:Create(frameId)
	local bar = self:super('Create', frameId)
	bar:SetAttribute('myAttributes', table.concat(BAR_ATTRIBUTES, ','))
	
	bar:Execute([[ WIDTH_OFFSET = 2; HEIGHT_OFFSET = 20 ]])
	
	bar:SetAttribute('_onstate-main', [[
		self:RunAttribute('lodas', string.split(',', self:GetAttribute('myAttributes')))
		self:RunAttribute('layout')
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
	
	bar:SetAttribute('layout', [[
		if not(myButtons and needsLayout) then return end

		local numButtons = #myButtons
		local cols = min(self:GetAttribute('state-columns'), numButtons)
		local rows = ceil(numButtons / cols)
		local spacing = self:GetAttribute('state-spacing')
		local pW, pH = self:GetAttribute('state-padW'), self:GetAttribute('state-padH')

		local b = myButtons[1]
		local w = b:GetWidth() + spacing - WIDTH_OFFSET
		local h = b:GetHeight() + spacing - HEIGHT_OFFSET

		for i, b in pairs(myButtons) do
			local col = (i-1) % cols
			local row = ceil(i / cols) - 1
			b:ClearAllPoints()
			b:SetPoint('TOPLEFT', self, 'TOPLEFT', w*col + pW, -(h*row + pH) + HEIGHT_OFFSET)
		end

		self:SetWidth(max(w*cols - spacing + pW*2 + WIDTH_OFFSET, 8))
		self:SetHeight(max(h*ceil(numButtons/cols) - spacing + pH*2, 8))
		
		needsLayout = nil
	]])
	
	--add button method
	bar:SetAttribute('addButton', [[
		local button = self:GetFrameRef('addButton')		
		if button then
			myButtons = myButtons or table.new()
			table.insert(myButtons, button)
			button:SetParent(self)
		end
	]])
	
	--load buttons
	for _, button in ipairs(MENU_BUTTONS) do
		bar:AddButton(button)
	end
	
	return bar
end

function MenuBar:AddButton(button)
	self:SetFrameRef('addButton', button)
	self:Execute([[ self:RunAttribute('addButton') ]])
end

function MenuBar:LoadButtons()
	for i, button in ipairs(menuButtons) do
		self:AddButton(button)
	end
end