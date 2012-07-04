--[[
	StanceBar.lua
		A bar that contains class buttons
--]]

if select(2, UnitClass('player')) == 'SHAMAN' or select(2, UnitClass('player')) == 'MAGE' then
	return
end

local AddonName, Addon = ...
local StanceBar = LibStub('Classy-1.0'):New('Frame', Addon.ButtonBar); Addon.StanceBar = StanceBar
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS

function StanceBar:New(settings)
	local f = StanceBar.Super('New', self, 'class', settings)
	
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

function StanceBar:Create(frameId)
	local bar = StanceBar.Super('Create', self, frameId)
	
	bar:SetAttribute('state-numButtons', GetNumShapeshiftForms())
	
	bar:Execute([[
		PADW_OFFSET = 4
		PADH_OFFSET = 4
	]])
	
	--load buttons
	for i = 1, NUM_STANCE_SLOTS do
		local b = _G['StanceButton' .. i]
		
		local r = b:GetWidth() / 36
		local nt = b:GetNormalTexture()
		nt:ClearAllPoints()
		nt:SetPoint('TOPLEFT', -15 * r, 15 * r)
		nt:SetPoint('BOTTOMRIGHT', 15 * r, -15 * r)
		
		bar:SetFrameRef('addButton', b)
		bar:Execute([[ self:RunAttribute('addButton') ]])
	end
	
	bar:SetScript('OnEvent', self.OnEvent)
	
	return bar
end

function StanceBar:OnEvent(event, ...)
	if event == 'PLAYER_ENTERING_WORLD' or event == 'UPDATE_SHAPESHIFT_FORMS' then
		self:UpdateNumForms()
	end
	
	self:UpdateForms()
end

function StanceBar:UpdateNumForms()
	self:SetAttribute('state-numButtons', GetNumShapeshiftForms())
	self:Execute([[ self:RunAttribute('layout') ]])
end

function StanceBar:UpdateForms()
	for i = 1, GetNumShapeshiftForms() do
		local texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)
		local button = _G['StanceButton' .. i]	
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