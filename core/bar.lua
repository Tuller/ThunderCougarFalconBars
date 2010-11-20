--[[
	frame.lua
		A dominos frame, a generic container object
--]]

local Frame = LibStub('Classy-1.0'):New('Frame')
local TCFB = select(2, ...)
TCFB.Frame = Frame

local frames = {}

local function frame_Create(id, o)
	local frame = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)

	frame:SetAttribute('id', id)

	frame:SetAttribute('_childupdate', [[
		self:SetAttribute(scriptid, message)
	]])

	frame:SetAttribute('_onstate-main', [[
		self:RunAttribute('lodas', string.split(',', self:GetAttribute('loadAttributes')))
	]])

	frame:SetAttribute('_onstate-lock', [[
		print('i\'m lockin!', newstate)
	]])

	-- load many state attributes
	frame:SetAttribute('lodas', [[
		local state = self:GetAttribute('state-main')

		for i = 1, select('#', ...) do
			local atr = (select(i, ...))

			local oldVal = self:GetAttribute('state-' .. atr)
			local newVal = self:RunAttribute('geta', atr, state)
			if oldVal ~= newVal then
				self:SetAttribute('state-' .. atr, newVal)
			end
		end
	]])

	--load a single state attribute
	frame:SetAttribute('loda', [[
		local atr = (select(i, ...))
		local oldVal = self:GetAttribute('state-' .. atr)
		local newVal = self:RunAttribute('geta', atr, state)
		if oldVal ~= newVal then
			self:SetAttribute('state-' .. atr, newVal)
		end
	]])

	frame:SetAttribute('seta', [[
		local atr, newValue, state = ...
		state = state or self:GetAttribute('state-main')

		local oldValue = self:RunAttribute('geta', atr, state)
		if oldValue ~= newValue then
			self:SetAttribute(atr .. '-' .. state, newVal)
			self:CallMethod('SaveAttribute', state, atr, newVal)
		end
	]])

	frame:SetAttribute('geta', [[
		local atr, state = ...

		local v = self:GetAttribute(atr .. '-' .. state)
		if v == nil then
			v = self:GetAttribute(atr .. '-default')
		end
		return v
	]])

	frame:SetAttribute('_onstate-show', [[
		if newstate then
			self:Show()
		else
			self:Hide()
		end
	]])

	frame:SetAttribute('_onstate-alpha', [[
		self:SetAlpha(newstate)
	]])

	frame:SetAttribute('_onstate-scale', [[
		self:SetScale(newstate)
	]])

	frame:SetAttribute('_onstate-point', [[
		local point, relPoint, xOff, yOff = string.split(',', newstate)

		self:ClearAllPoints()
		self:SetPoint(point, self:GetParent(), relPoint, xOff, yOff)
	]])

	return frame
end

function Frame:New(frameId, settings)
	local f = self:Bind(frame_Create(frameId))
	f:SetAttribute('loadAttributes', 'show,scale,alpha,point')
	f.sets = settings

	f:LoadAttributes()
	TCFB.MajorTom:addFrame(f)
	frames[frameId] = f

	return f
end

function Frame:Get(frameId)
	return frames[frameId]
end


--attributes
function Frame:SetAtr(attribute, value, state)
	return self:RunAttribute('seta', attribute, value, state)
end

function Frame:GetAtr(attribute, value, state)
	return self:RunAttribute('geta', attribute, value, state)
end

function Frame:SaveAttribute(state, attribute, value)
	local stateSets = self.sets[state]
	if not stateSets then
		self.sets[state] = {[attribute] = value}
	end
	stateSets[attribute] = value
end

function Frame:LoadAttributes()
	for state, attributes in pairs(self.sets) do
		for atr, value in pairs(attributes) do
			self:SetAttribute(atr .. '-' .. state, value)
		end
	end
end
