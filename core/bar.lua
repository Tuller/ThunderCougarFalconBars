--[[
	bar.lua
		A movable container object
--]]

local Bar = LibStub('Classy-1.0'):New('Frame')
local TCFB = select(2, ...)
TCFB.Bar = Bar

local DELIMITER = ';' --compact settings delimiter
local active, destroyed = {}, {}

local function frame_Create(id)
	local frame = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:SetAttribute('id', id)

	frame:SetAttribute('_childupdate', [[
		self:SetAttribute(scriptid, message)
	]])

	frame:SetAttribute('_onstate-main', [[
		self:RunAttribute('lodas', string.split(',', self:GetAttribute('myAttributes')))
	]])

	frame:SetAttribute('_onstate-lock', [[
		self:ChildUpdate('state-lock', newstate)
		self:GetFrameRef('dragFrame'):SetAttribute('state-lock', newstate)
	]])

	frame:SetAttribute('_onstate-destroy', [[
		self:CallMethod('ForDocked', 'ClearAnchor')
		self:CallMethod('SetUserPlaced', false)

		self:ChildUpdate('state-destroy', newstate)
		self:GetFrameRef('dragFrame'):SetAttribute('state-destroy', newstate)
	]])

	-- load many state attributes
	frame:SetAttribute('lodas', [[
		local state = self:GetAttribute('state-main') or 'default'

		for i = 1, select('#', ...) do
			local id = select(i, ...)
			self:RunAttribute('loda', id, state)
		end
	]])

	frame:SetAttribute('loda', [[
		local id, state = ...
		state = state or 'default'

		local oldVal = self:GetAttribute('state-' .. id)
		local newVal = self:RunAttribute('geta', id, state)
		if oldVal ~= newVal then
			self:SetAttribute('state-' .. id, newVal)
		end
	]])

	frame:SetAttribute('geta', [[
		local id, state = ...
		state = state or 'default'

		local v = self:GetAttribute(id .. '-' .. state)
		if v == nil then
			return self:GetAttribute(id .. '-default')
		end
		return v
	]])

	frame:SetAttribute('_onstate-enable', [[
		self:ChildUpdate('state-enable', newstate)
		self:GetFrameRef('dragFrame'):SetAttribute('state-enable', newstate)
	]])

	frame:SetAttribute('_onstate-show', [[
		local show = newstate
		if show then
			self:Show()
		else
			self:Hide()
		end
		self:GetFrameRef('dragFrame'):CallMethod('UpdateColor')
	]])

	frame:SetAttribute('_onstate-alpha', [[
		local alpha = newstate
		self:SetAlpha(alpha)
	]])

	frame:SetAttribute('_onstate-scale', [[
		local scale = newstate
		self:SetScale(scale)
		self:GetFrameRef('dragFrame'):SetScale(scale)
	]])

	frame:SetAttribute('_onstate-point', [[
		self:RunAttribute('reposition')
	]])

	frame:SetAttribute('_onstate-anchor', [[
		self:RunAttribute('reposition')
		self:GetFrameRef('dragFrame'):CallMethod('UpdateColor')
	]])

	frame:SetAttribute('reposition', [[
		self:ClearAllPoints()

		local anchor = self:GetAttribute('state-anchor')
		if anchor then
			local point, frameId, relPoint, x, y = string.split(';', anchor)
			if self:GetParent():RunAttribute('placeFrame', self:GetAttribute('id'), point, frameId, relPoint, x, y) then
				self:CallMethod('SetUserPlaced', true)
				return
			end
		end

		local place = self:GetAttribute('state-point')
		if place then
			local point, x, y = string.split(';', place)
			self:SetPoint(point, self:GetParent(), point, x, y)
			self:CallMethod('SetUserPlaced', true)
			return
		end

		self:SetPoint('CENTER', self:GetParent(), 'CENTER', 0, 0)
		self:CallMethod('SetUserPlaced', false)
	]])

	return frame
end

function Bar:New(frameId, settings)
	local f = self:Restore(frameId) or self:Create(frameId)
	f:LoadSettings(settings)

	TCFB.MajorTom:addFrame(f)
	active[frameId] = f

	return f
end

function Bar:Create(frameId)
	local f = self:Bind(frame_Create(frameId))
	f:SetAttribute('myAttributes', 'enable,show,scale,alpha,point,anchor')
	f:SetFrameRef('dragFrame', TCFB.DragFrame:New(f))

	return f
end

function Bar:Restore(frameId)
	local f = destroyed[frameId]
	if f then
		destroyed[frameId] = nil
		return f
	end
end

function Bar:Free()
	active[self:GetAttribute('id')] = nil
	TCFB.MajorTom:removeFrame(self)
	destroyed[self:GetAttribute('id')] = self
end


--[[ frame access ]]--


function Bar:GetAll()
	return pairs(active)
end

function Bar:GetBar(frameId)
	return active[tonumber(frameId) or frameId]
end

function Bar:ForAll(method, ...)
	local action = type(method) == 'string' and self[method] or method
	for _,f in self:GetAll() do
		action(f, ...)
	end
end

function Bar:ForDocked(method, ...)
	local action = type(method) == 'string' and self[method] or method
	for _,f in self:GetAll() do
		if select(2, f:GetAnchor()) == tostring(self:GetAttribute('id')) then
			action(f, ...)
		end
	end
end


--[[ state settings ]]--

function Bar:Set(attribute, newValue, state)
	state = state or self:GetAttribute('state-main')

	local oldValue = self:Get(attribute, state)
	if oldValue ~= newValue then
		self:SetAttribute(attribute .. '-' .. state, newValue)
		self:Save(attribute, newValue, state)

		--if we've adjusted a current attribute, then update it
		if state == self:GetAttribute('state-main') then
			self:SetAttribute('state-' .. attribute, newValue)
		end
	end
end

function Bar:Get(attribute, state)
	state = state or self:GetAttribute('state-main')

	local v = self:GetAttribute(attribute .. '-' .. state)
	if v == nil then
		v = self:GetAttribute(attribute .. '-default')
	end
	return v
end

function Bar:Save(attribute, value, state)
	state = state or self:GetAttribute('state-main')

	local stateSets = self.sets[state]
	if not stateSets then
		self.sets[state] = {[attribute] = value}
	end

	stateSets[attribute] = value
end

function Bar:LoadSettings(settings)
	self.sets = settings
	for state, attributes in pairs(settings) do
		for attribute, value in pairs(attributes) do
			self:Set(attribute, value, state)
		end
	end
end

--frame placement
Bar.stickyTolerance = 16

function Bar:StickToEdge()
	local point, x, y = self:GetRelPosition()
	local s = self:GetScale()
	local w = self:GetParent():GetWidth()/s
	local h = self:GetParent():GetHeight()/s
	local rTolerance = self.stickyTolerance/s
	local changed = false

	--sticky edges
	if abs(x) <= rTolerance then
		x = 0
		changed = true
	end

	if abs(y) <= rTolerance then
		y = 0
		changed = true
	end

	-- auto centering
	local cX, cY = self:GetCenter()
	if y == 0 then
		if abs(cX - w/2) <= rTolerance*2 then
			if point == 'TOPLEFT' or point == 'TOPRIGHT' then
				point = 'TOP'
			else
				point = 'BOTTOM'
			end

			x = 0
			changed = true
		end
	elseif x == 0 then
		if abs(cY - h/2) <= rTolerance*2 then
			if point == 'TOPLEFT' or point == 'BOTTOMLEFT' then
				point = 'LEFT'
			else
				point = 'RIGHT'
			end

			y = 0
			changed = true
		end
	end

	--save this junk if we've done something
	if changed then
		self:Set('point', string.join(DELIMITER, point, x, y))
	end
end

function Bar:Stick()
	self:SaveRelPosition()
	self:ClearAnchor()

	--only do sticky code if the alt key is not currently down
	if not IsAltKeyDown() then
		local anchored = false

		--try to stick to a bar, then try to stick to a screen edge
		for _, f in self:GetAll() do
			if f ~= self then
				local point = FlyPaper.Stick(self, f, self.stickyTolerance)
				if point then
					self:SetAnchor(self:GetPoint())
					anchored = true
					break
				end
			end
		end

		if not anchored then
			self:StickToEdge()
		end
	end

	self.drag:UpdateColor()
end

function Bar:SetAnchor(point, frame, relPoint, x, y)
	self:Set('anchor', string.join(DELIMITER, point, frame:GetAttribute('id'), relPoint, x, y))
end

function Bar:GetAnchor()
	local anchor = self:Get('anchor')
	if anchor then
		return string.split(';', anchor)
	end
end

function Bar:ClearAnchor()
	self:SaveRelPosition()
	self:Set('anchor', false)
end


--[[ Positioning ]]--

function Bar:GetRelPosition()
	local parent = self:GetParent()
	local w, h = UIParent:GetSize()
	local x, y = self:GetCenter()
	local s = self:GetScale()
	w = w/s h = h/s

	local dx, dy
	local hHalf = (x > w/2) and 'RIGHT' or 'LEFT'
	if hHalf == 'RIGHT' then
		dx = self:GetRight() - w
	else
		dx = self:GetLeft()
	end

	local vHalf = (y > h/2) and 'TOP' or 'BOTTOM'
	if vHalf == 'TOP' then
		dy = self:GetTop() - h
	else
		dy = self:GetBottom()
	end

	return vHalf..hHalf, dx, dy
end

function Bar:SaveRelPosition()
	self:Set('point', string.join(DELIMITER, self:GetRelPosition()))
end

--[[ Scaling ]]--

function Bar:GetScaledCoords(scale)
	local ratio = self:Get('scale') / scale
	return (self:GetLeft() or 0) * ratio, (self:GetTop() or 0) * ratio
end

function Bar:SetFrameScale(scale, scaleDocked)
	local x, y =  self:GetScaledCoords(scale)

	self:Set('scale', scale)

	if not self:Get('anchor') then
		self:ClearAllPoints()
		self:SetPoint('TOPLEFT', self:GetParent(), 'BOTTOMLEFT', x, y)
		self:SaveRelPosition()
	end

	if scaleDocked then
		self:ForDocked('SetFrameScale', scale, true)
	end
end