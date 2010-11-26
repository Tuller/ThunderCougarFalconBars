local TCFB = select(2, ...)
local ClassBar = LibStub('Classy-1.0'):New('Frame', TCFB.Bar)
TCFB.ClassBar = ClassBar

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

function ClassBar:New(settings)
	local f = self:super('New', 'class', settings)
	
	f:RegisterEvent('PLAYER_ENTERING_WORLD')
	f:RegisterEvent('UPDATE_SHAPESHIFT_FORMS')
	f:RegisterEvent('UPDATE_SHAPESHIFT_USABLE')
	f:RegisterEvent('UPDATE_SHAPESHIFT_COOLDOWN')
	f:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
	f:RegisterEvent('UPDATE_INVENTORY_ALERTS')
	f:RegisterEvent('ACTIONBAR_PAGE_CHANGED')
	
	f:UpdateNumForms()
	f:UpdateForms()
	
	return f
end

function ClassBar:Create(frameId)
	local bar = self:super('Create', frameId)
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
	
	bar:Execute([[ SPACING_OFFSET = 0; PADDING_OFFSET = 4 ]])

	bar:SetAttribute('layout', [[
		if not(myButtons and needsLayout) then return end

		local numForms = self:GetAttribute('state-numForms')
		local numButtons = #myButtons
		local cols = min(self:GetAttribute('state-columns'), numForms)
		local rows = ceil(numForms / cols)
		local spacing = self:GetAttribute('state-spacing') + SPACING_OFFSET
		local pW = self:GetAttribute('state-padW') + PADDING_OFFSET 
		local pH = self:GetAttribute('state-padH') + PADDING_OFFSET

		local b = myButtons[1]
		local w = b:GetWidth() + spacing
		local h = b:GetHeight() + spacing
		
		for i = numForms + 1, numButtons do
			local b = myButtons[i]
			b:Hide()
		end
		
		if numForms > 0 then
			for i = 1, numForms do
				local b = myButtons[i]
				local col = (i-1) % cols
				local row = ceil(i / cols) - 1
				
				b:ClearAllPoints()
				b:SetPoint('TOPLEFT', self, 'TOPLEFT', w*col + pW, -(h*row + pH))
				b:Show()
			end

			self:SetWidth(max(w*cols - spacing + pW*2, 8))
			self:SetHeight(max(h*rows - spacing + pH*2, 8))
		else
			self:SetWidth(w - spacing + pW*2)
			self:SetHeight(h - spacing + pH*2)
		end
		
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
	for i = 1, NUM_SHAPESHIFT_SLOTS do
		local b = _G['ShapeshiftButton' .. i]
		
		local r = b:GetWidth() / 36
		local nt = b:GetNormalTexture()
		nt:ClearAllPoints()
		nt:SetPoint('TOPLEFT', -15 * r, 15 * r)
		nt:SetPoint('BOTTOMRIGHT', 15 * r, -15 * r)
		
		bar:SetFrameRef('addButton', b)
		bar:Execute([[ self:RunAttribute('addButton') ]])
	end
	bar:SetAttribute('state-numForms', GetNumShapeshiftForms())
	
	bar:SetScript('OnEvent', self.OnEvent)
	
	return bar
end

function ClassBar:OnEvent(event, ...)
	if event == 'PLAYER_ENTERING_WORLD' or event == 'UPDATE_SHAPESHIFT_FORMS' then
		self:UpdateNumForms()
	end
	self:UpdateForms()
end

function ClassBar:UpdateNumForms()
	self:SetAttribute('state-numForms', GetNumShapeshiftForms())
	self:Execute([[ self:RunAttribute('layout') ]])
end

function ClassBar:UpdateForms()
	local numForms = GetNumShapeshiftForms()
	
	for i = 1, numForms do
		local texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)
		local button = _G['ShapeshiftButton' .. i]	
		local icon = _G[button:GetName() .. 'Icon']
		local cooldown = _G[button:GetName() .. 'Cooldown']
		
		icon:SetTexture(texture)
		if isCastable then
			icon:SetVertexColor(1.0, 1.0, 1.0)
		else
			icon:SetVertexColor(0.4, 0.4, 0.4)
		end
		
		if texture then
			CooldownFrame_SetTimer(cooldown, GetShapeshiftFormCooldown(i))
		else
			cooldown:Hide()
		end

		button:SetChecked(isActive)
	end
end