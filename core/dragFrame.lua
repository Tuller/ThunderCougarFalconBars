--[[
	dragFrame.lua
		A frame component that controls frame movement
--]]

local TCFB = select(2, ...)
local DragFrame = LibStub('Classy-1.0'):New('Button')
TCFB.DragFrame = DragFrame

local L = LibStub('AceLocale-3.0'):GetLocale('ThunderCougarFalconBars')
local round = function(x) return floor(x + 0.5) end
local backdrop = {
	bgFile   = 	[[Interface\ChatFrame\ChatFrameBackground]],
	edgeFile = 	[[Interface\ChatFrame\ChatFrameBackground]],
	edgeSize = 	2,
	insets   = 	{ left = 2, right = 2, top = 2, bottom = 2 },
}

function DragFrame:New(owner)
	local f = self:Bind(CreateFrame('Button', nil, owner:GetParent()))
	f.owner = owner; owner.drag = f
	f.scaler = TCFB.ScaleButton:New(f)

	f:EnableMouseWheel(true)
	f:SetClampedToScreen(true)
	f:SetFrameStrata(owner:GetFrameStrata())
	f:SetAllPoints(owner)
	f:SetFrameLevel(owner:GetFrameLevel() + 5)
	f:SetBackdrop(backdrop)

--[[
	local bg = f:CreateTexture(nil, 'BACKGROUND')
	bg:SetTexture(1, 1, 1, 0.4)
	bg:SetAllPoints(f)
	f:SetNormalTexture(bg)

	local t = f:CreateTexture(nil, 'BACKGROUND')
	t:SetTexture(0.2, 0.3, 0.4, 0.5)
	t:SetAllPoints(f)
	f:SetHighlightTexture(t)
--]]

	f:SetNormalFontObject('GameFontNormalLarge')
	f:SetText(owner:GetAttribute('id'))

	f:RegisterForClicks('AnyUp')
	f:RegisterForDrag('LeftButton')
	f:SetScript('OnAttributeChanged', self.OnAttributeChanged)
	f:SetScript('OnMouseDown', self.StartMoving)
	f:SetScript('OnMouseUp', self.StopMoving)
	f:SetScript('OnMouseWheel', self.OnMouseWheel)
	f:SetScript('OnClick', self.OnClick)
	f:SetScript('OnEnter', self.OnEnter)
	f:SetScript('OnLeave', self.OnLeave)
	f:SetAttribute('state-enable', f:GetAttribute('state-enable'))
	f:SetAttribute('state-lock', f:GetAttribute('state-lock'))
	f:SetHighlight(false)

	return f
end

function DragFrame:OnAttributeChanged(...)
	local enabled = self:GetAttribute('state-enable')
	local locked = self:GetAttribute('state-lock')
	local destroyed = self:GetAttribute('state-destroy')

	if enabled and not(locked or destroyed) then
		self:Show()
	else
		self:Hide()
	end
end

function DragFrame:OnEnter()
	self:SetHighlight(true)

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
	self:UpdateTooltip()
end

function DragFrame:UpdateTooltip()
	if not GameTooltip:IsOwned(self) then return end

	GameTooltip:SetText(format('Bar: %s', self:GetText():gsub('^%l', string.upper)), 1, 1, 1)

	-- local tooltipText = self.owner:GetTooltipText()
	-- if tooltipText then
		-- GameTooltip:AddLine(tooltipText .. '\n', nil, nil, nil, nil, 1)
	-- end

	-- if self.owner.ShowMenu then
		-- GameTooltip:AddLine(L.ShowConfig)
	-- end

	if self.owner:Get('show') then
		GameTooltip:AddLine(L.HideBar)
	else
		GameTooltip:AddLine(L.ShowBar)
	end

	GameTooltip:AddLine(format(L.SetAlpha, round(self.owner:Get('alpha') * 100)))
	GameTooltip:Show()
end

function DragFrame:OnLeave()
	self:SetHighlight(nil)
	GameTooltip:Hide()
end

function DragFrame:SetHighlight(enable)
	if enable then
		self.highlight = (self.highlight or 0) + 1
	else
		self.highlight = (self.highlight or 0) - 1
	end
	self.highlight = max(self.highlight, 0)

	if self.highlight > 0 then
		self:SetBackdropBorderColor(1, 0.8, 0, 1)
	else
		self:SetBackdropBorderColor(0, 0, 0, 0.5)
	end
end

function DragFrame:StartMoving(button)
	if button == 'LeftButton' then
		self.isMoving = true
		self.owner:StartMoving()
		self:OnLeave()
	end
end

function DragFrame:StopMoving()
	if self.isMoving then
		self.isMoving = nil
		self.owner:StopMovingOrSizing()
		self.owner:Stick()
		self:OnEnter()
	end
end

function DragFrame:OnMouseWheel(arg1)
	local alpha = self.owner:Get('alpha')
	local newAlpha = min(max(alpha + (arg1 * 0.05), 0), 1)
	if newAlpha ~= alpha then
		self.owner:Set('alpha', newAlpha)
		self:UpdateTooltip()
	end
end

function DragFrame:OnClick(button)
	if button == 'RightButton' then
		if IsShiftKeyDown() then
			self.owner:Set('show', not self.owner:Get('show'))
		-- else
			-- self.owner:ShowMenu()
		end
	elseif button == 'MiddleButton' then
		self.owner:Set('show', not self.owner:Get('show'))
	end
	self:UpdateTooltip()
end

--updates the DragFrame button color of a given bar if its attached to another bar
function DragFrame:UpdateColor()
	if self.owner:Get('show') then
		if self.owner:Get('anchor') then
			self:SetBackdropColor(0.125, 0.125, 0.75/2, 0.5)
		else
			self:SetBackdropColor(0.25, 0.25, 0.75, 0.5)
		end
	else
		if self.owner:Get('anchor') then
			self:SetBackdropColor(0.25, 0.25, 0.25, 0.5)
		else
			self:SetBackdropColor(0.5, 0.5, 0.5, 0.5)
		end
	end
end