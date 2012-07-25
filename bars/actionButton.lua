--[[
	actionBar.lua
		the code for Dominos action bars and buttons
--]]

local AddonName, Addon = ...
local ActionButton = Addon:NewFrameClass('CheckButton', Addon.BindableButton); Addon.ActionButton = ActionButton

--libs and omgspeed
local KeyBound = LibStub('LibKeyBound-1.0')
local _G = _G
local format = string.format


--[[ Action Button ]]--

ActionButton.unused = {}
ActionButton.active = {}

--constructor
function ActionButton:New(id)
	local b = self:Restore(id) or self:Create(id)
	if b then
		b:SetAttribute('showgrid', 0)
		b:SetAttribute('action-base', id)
		b:SetAttribute('action', id)

		b:UpdateGrid()
		b:UpdateHotkey(b.buttonType)
		b:UpdateMacro()

		--hack #1billion, get rid of range indicator text
		local hotkey = _G[b:GetName() .. 'HotKey']
		if hotkey:GetText() == _G['RANGE_INDICATOR'] then
			hotkey:SetText('')
		end

		self.active[id] = b

		return b
	end
end

local function actionButton_Create(id)
	if id <= 12 then
		local b = _G['ActionButton' .. id]
		b.buttonType = 'ACTIONBUTTON'
		return b
	elseif id <= 24 then
		return _G['MultiBarRightButton' .. (id-12)]
	elseif id <= 36 then
		return _G['MultiBarLeftButton' .. (id-24)]
	elseif id <= 48 then
		return _G['MultiBarBottomRightButton' .. (id-36)]
	elseif id <= 60 then
		return _G['MultiBarBottomLeftButton' .. (id-48)]
	end
	return CreateFrame('CheckButton', format('%sActionButton%d', AddonName, (id - 60)), nil, 'ActionBarButtonTemplate')
end

function ActionButton:Create(id)
	local b = actionButton_Create(id)
	if b then
		self:Bind(b)

		--this is used to preserve the button's old id
		--we cannot simply keep a button's id at > 0 or blizzard code will take control of paging
		--but we need the button's id for the old bindings system
		b:SetAttribute('bindingid', b:GetID())
		b:SetID(0)

		b:ClearAllPoints()
		b:SetAttribute('useparent-actionpage', nil)
		b:SetAttribute('useparent-unit', true)
		b:EnableMouseWheel(true)
		b:SetScript('OnEnter', self.OnEnter)
		b:Skin()
	end
	return b
end

function ActionButton:Restore(id)
	local b = self.unused[id]
	if b then
		self.unused[id] = nil
		b:LoadEvents()
		ActionButton_UpdateAction(b)
		b:Show()
		self.active[id] = b
		return b
	end
end

--destructor
function ActionButton:Free()
	local id = self:GetAttribute('action-base')

	self.active[id] = nil

	self:UnregisterAllEvents()
	self:SetParent(nil)
	self:Hide()
	self.eventsRegistered = nil
	self.action = nil

	self.unused[id] = self
end

--these are all events that are registered OnLoad for action buttons
function ActionButton:LoadEvents()
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('ACTIONBAR_SHOWGRID')
	self:RegisterEvent('ACTIONBAR_HIDEGRID')
	self:RegisterEvent('ACTIONBAR_PAGE_CHANGED')
	self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
	self:RegisterEvent('UPDATE_BINDINGS')
end

--keybound support
function ActionButton:OnEnter()
	ActionButton_SetTooltip(self)
	KeyBound:Set(self)
end

--override the old update hotkeys function
hooksecurefunc('ActionButton_UpdateHotkeys', ActionButton.UpdateHotkey)

--button visibility
function ActionButton:UpdateGrid()
	if self:GetAttribute('showgrid') > 0 then
		ActionButton_ShowGrid(self)
	else
		ActionButton_HideGrid(self)
	end
end

--macro text
function ActionButton:UpdateMacro()
	local macroText = _G[self:GetName() .. 'Name'];	
	if self:GetAttribute('showmacro') then
		macroText:Show()
	else
		macroText:Hide()
	end
end

--utility function, resyncs the button's current action, modified by state
function ActionButton:Skin()
	_G[self:GetName() .. 'Icon']:SetTexCoord(0.06, 0.94, 0.06, 0.94)
	self:GetNormalTexture():SetVertexColor(1, 1, 1, 0.5)
end