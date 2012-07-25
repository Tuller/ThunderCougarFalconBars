--[[
	buttonBar.lua
		A bar that contains a set of buttons in a grid
--]]

local AddonName, Addon = ...
local ButtonBar = Addon:NewFrameClass('Frame', Addon.Bar); Addon.ButtonBar = ButtonBar

local ButtonBarAttributes = {
	'columns',
	'spacing',
	'padW',
	'padH'
}

ButtonBar.BAR_ATTRIBUTES = Addon.Utility:ConcatArrays(Addon.Bar.BAR_ATTRIBUTES, ButtonBarAttributes)

function ButtonBar:Create(frameId)
	local bar = ButtonBar.Super('Create', self, frameId)
	
	--[[ init any bar global variables ]]--
	
	bar:Execute([[
		SPACING_OFFSET = 0
		PADW_OFFSET = 0
		PADH_OFFSET = 0
		HEIGHT_OFFSET = 0
		WIDTH_OFFSET = 0
	]])
	
	--[[ 
		after a layout value is altered, set a dirty bit indicating that we need to adjust the bar's layout 
	--]]
	
	bar:SetAttribute('_onstate-numButtons', [[
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
	
	bar:SetAttribute('postMain', [[
		self:RunAttribute('layout')
	]])
	
	--add button method
	bar:SetAttribute('addButton', [[
		local button = self:GetFrameRef('addButton')		
		if button then
			myButtons = myButtons or table.new()
			table.insert(myButtons, button)
			button:SetParent(self:GetFrameRef('buttonFrame') or self)
		end
	]])
	
	bar:SetAttribute('layout', [[
		if not(myButtons and needsLayout) then return end

		local numButtons = self:GetAttribute('state-numButtons') or #myButtons
		local cols = min(self:GetAttribute('state-columns') or numButtons, numButtons)
		local rows = ceil(numButtons / cols)
		local spacing = self:GetAttribute('state-spacing') + SPACING_OFFSET
		local pW = self:GetAttribute('state-padW') + PADW_OFFSET
		local pH = self:GetAttribute('state-padH') + PADH_OFFSET

		local b = myButtons[1]
		local w = (b:GetWidth() or 0) + spacing
		local h = (b:GetHeight() or 0) + spacing
		
		for i = numButtons + 1, #myButtons do
			myButtons[i]:Hide()
		end

		if numButtons > 0 then
			for i = 1, numButtons do
				local col = (i-1) % cols
				local row = ceil(i / cols) - 1
			
				local b = myButtons[i]
				b:ClearAllPoints()
				b:SetPoint('TOPLEFT', self, 'TOPLEFT', w*col + pW + WIDTH_OFFSET, -(h*row + pH) + HEIGHT_OFFSET)
				b:Show()
			end
		end
		
		self:SetWidth(max(w*cols - spacing + pW*2 - WIDTH_OFFSET, 8))
		self:SetHeight(max(h*rows - spacing + pH*2 - HEIGHT_OFFSET, 8))	
		
		needsLayout = nil
	]])

	return bar
end

function ButtonBar:AddButton(button)
	self:SetFrameRef('addButton', button)
	self:Execute([[ self:RunAttribute('addButton') ]])
end

function ButtonBar:SetNumButtons(numButtons)
	self:Set('numButtons', numButtons or false) --here, false implies (use whatever the maximum value would be)
	self:Execute([[ self:RunAttribute('layout') ]])
end

function ButtonBar:SetColumns(columns)
	self:Set('columns', columns or false) --here, false implies (use whatever the maximum value would be)
	self:Execute([[ self:RunAttribute('layout') ]])
end

function ButtonBar:SetSpacing(spacing)
	self:Set('spacing', spacing or 0)
	self:Execute([[ self:RunAttribute('layout') ]])
end

function ButtonBar:SetPadding(padW, padH)
	local padW = padW or 0
	local padH = padH or padW

	self:Set('padW', padW)
	self:Set('padH', padH)
	self:Execute([[ self:RunAttribute('layout') ]])
end