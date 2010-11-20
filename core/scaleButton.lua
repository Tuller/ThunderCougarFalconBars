--[[
	scaleButton.lua
		A frame for dragging + scaling frames
--]]

local TCFB = select(2, ...)
local ScaleButton = LibStub('Classy-1.0'):New('Button')
TCFB.ScaleButton = ScaleButton

function ScaleButton:New(parent)
	local f = self:Bind(CreateFrame('Button', nil, parent))
	f:SetFrameLevel(parent:GetFrameLevel() + 3)
	f:SetPoint('BOTTOMRIGHT', parent)
	f:SetSize(16, 16)

	f:SetNormalTexture([[Interface\RaidFrame\Raid-Move-Up]])

	f:SetScript('OnEnter', self.OnEnter)
	f:SetScript('OnLeave', self.OnLeave)
	f:SetScript('OnMouseDown', self.StartScaling)
	f:SetScript('OnMouseUp', self.StopScaling)
	f.owner = parent.owner

	return f
end

--credit goes to AnduinLothar for this code, I've only modified it to work with Bongos/Sage
function ScaleButton:OnUpdate(elapsed)
	local frame = self.owner
	local x, y = GetCursorPosition()
	local currScale = frame:GetEffectiveScale()
	x = x / currScale
	y = y / currScale

	local left, top = frame:GetLeft(), frame:GetTop()
	local wScale = (x-left)/frame:GetWidth()
	local hScale = (top-y)/frame:GetHeight()

	local scale = max(min(max(wScale, hScale), 1.2), 0.8)
	local newScale = min(max(frame:GetScale() * scale, 0.5), 1.5)
	frame:SetFrameScale(newScale)
end

function ScaleButton:StartScaling()
	if not IsAltKeyDown() then
		self.isScaling = true
		self:GetParent():LockHighlight()
		self:SetScript('OnUpdate', self.OnUpdate)
	end
end

function ScaleButton:StopScaling()
	self.isScaling = nil
	self:GetParent():UnlockHighlight()
	self:SetScript('OnUpdate', nil)
end

function ScaleButton:OnEnter()
	self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8)
end

function ScaleButton:OnLeave()
	self:GetNormalTexture():SetVertexColor(1, 1, 1)
end
