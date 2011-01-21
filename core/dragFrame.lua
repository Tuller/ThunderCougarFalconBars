--[[
	dragFrame.lua
		A frame component that controls frame movement
--]]

local TCFB = select(2, ...)
local DragFrame = LibStub('Classy-1.0'):New('Button')
TCFB.DragFrame = DragFrame

local L = LibStub('AceLocale-3.0'):GetLocale('ThunderCougarFalconBars')
local round = function(x) return floor(x + 0.5) end

local FRAME_COLORS = {
	SHOWN = {r = 0.00, g = 0.22, b = 0.66, a = 0.5},
	HIDDEN = {r = 0.70, g = 0.11, b = 0.11, a = 0.5},
}

local FRAME_BACKDROP = {
	bgFile   = 	[[Interface\ChatFrame\ChatFrameBackground]],
	edgeFile = 	[[Interface\ChatFrame\ChatFrameBackground]],
	edgeSize = 	2,
	insets   = 	{ left = 2, right = 2, top = 2, bottom = 2 },
}

--[[
	Alpha fader
--]]

local function fader_OnStop(self)
	self:GetParent():SetAlpha(self.alpha)
end

local function fader_OnFinished(self)
	self:GetParent():SetAlpha(self.alpha)
	self:GetParent():UpdateColor()

	if self.alpha == 0 then
		self:GetParent():Hide()
	end
end

local function fader_Create(parent)
	local fader = parent:CreateAnimationGroup()
	fader:SetLooping('NONE')
	fader:SetScript('OnFinished', fader_OnFinished)
	fader:SetScript('OnStop', fader_OnStop)

	--start the animation as completely transparent
	local animator = fader:CreateAnimation('Alpha')
	animator:SetChange(1)
	animator:SetDuration(0.5)
	animator:SetOrder(0)
	fader.animator = animator

	parent.fader = fader
	return fader
end


--[[
	Color Fader
-=]]

local function colorFader_OnUpdate(self)
	local p = self.animator:GetSmoothProgress()
	local r = self.sR + (self.dR * p)
	local g = self.sG + (self.dG * p)
	local b = self.sB + (self.dB * p)
	local a = self.sA + (self.dA * p)
	
	self:saveColor(r, g, b, a)
end

local function colorFader_SetColor(self, fR, fG, fB, fA)
	if self:IsPlaying() then self:Stop() end
	
	local animator = self.animator
	local r, g, b, a = self:loadColor()
	
	self.sR = r
	self.sG = g
	self.sB = b
	self.sA = a
	
	self.dR = (fR - r)
	self.dG = (fG - g)
	self.dB = (fB - b)
	self.dA = (fA - a)
	
	self.fR = fR
	self.fG = fG
	self.fB = fB
	self.fA = fA
	
	self:Play()
	return self
end

local function colorFader_Create(parent, saveColor, loadColor)
	local fader = parent:CreateAnimationGroup()
	fader:SetLooping('NONE')
	fader.saveColor = saveColor
	fader.loadColor = loadColor

	--start the animation as completely transparent
	local animator = fader:CreateAnimation('Animation')
	animator:SetDuration(0.2)
	animator:SetOrder(0)
	fader.animator = animator
	
	fader.SetColor = colorFader_SetColor
	fader:SetScript('OnUpdate', colorFader_OnUpdate)
	fader:SetScript('OnStop', colorFader_OnStop)

	return fader	
end

function DragFrame:New(owner)
	local f = self:Bind(CreateFrame('Button', nil, owner:GetParent(), 'SecureHandlerBaseTemplate'))
	f.owner = owner; owner.drag = f
	f.scaler = TCFB.ScaleButton:New(f)

	f:EnableMouseWheel(true)
	f:SetClampedToScreen(true)
	f:SetFrameStrata(owner:GetFrameStrata())
	f:SetAllPoints(owner)
	f:SetFrameLevel(owner:GetFrameLevel() + 5)
	f:SetBackdrop(FRAME_BACKDROP)
	f:Hide()

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
		if not self:IsShown() then
			self:Unlock()
		end
	else
		if self:IsShown() then
			self:Lock()
		end
	end
end

function DragFrame:Lock()
	local fader = self.fader or fader_Create(self)
	if fader:IsPlaying() then
		fader:Stop()
	end
	
	fader.alpha = 0
	fader.animator:SetChange(-1)
	fader:Play()
end

function DragFrame:Unlock()
	self:SetAlpha(0)
	self:Show()
	
	local fader = self.fader or fader_Create(self)
	if not fader:IsPlaying() then
		fader.alpha = 1
		fader.animator:SetChange(1)
		fader:Play()
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
		self:SetBorderColor(1, 0.8, 0, 1)
	else
		self:SetBorderColor(0, 0, 0, 0.5)
	end
end

function DragFrame:StartMoving(button)
	if button == 'LeftButton' then
		self.isMoving = true
		self.owner:StartMoving()
		self:SetHighlight(true)
		self:OnLeave()
	end
end

function DragFrame:StopMoving()
	if self.isMoving then
		self.isMoving = nil
		self.owner:StopMovingOrSizing()
		self.owner:Stick()
		self:SetHighlight(false)
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
	local color = FRAME_COLORS[self.owner:Get('show') and 'SHOWN' or 'HIDDEN']
	local r = color.r
	local g = color.g
	local b = color.b
	local a = color.a

	if self.owner:Get('anchor') then
		r = r/2
		g = g/2
		b = b/2
	end

	self:SetColor(r, g, b, a)
end

function DragFrame:SetBorderColor(r, g, b, a)
	local pR, pG, pB, pA = self:GetBackdropBorderColor()
	if not(r == pR and g == pG and b == pB and a == pA) then
		local fader = self.borderFader
		if not fader then
			fader = colorFader_Create(self); self.borderFader = fader
			
			fader.saveColor = function(self, r, g, b, a) 
				return self:GetParent():SetBackdropBorderColor(r, g, b, a) 
			end
			
			fader.loadColor = function(self)
				return self:GetParent():GetBackdropBorderColor()
			end
		end
		fader:SetColor(r, g, b, a)
	end
end

function DragFrame:SetColor(r, g, b, a)
	local pR, pG, pB, pA = self:GetBackdropColor()
	if not(r == pR and g == pG and b == pB and a == pA) then
		local fader = self.colorFader
		if not fader then
			fader = colorFader_Create(self); self.colorFader = fader
		
			fader.saveColor = function(self, r, g, b, a) 
				return self:GetParent():SetBackdropColor(r, g, b, a) 
			end
		
			fader.loadColor = function(self)
				return self:GetParent():GetBackdropColor()
			end
		end
		fader:SetColor(r, g, b, a)
	end
end