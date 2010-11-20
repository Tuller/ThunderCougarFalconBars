--[[
	frame.lua
		A dominos frame, a generic container object
--]]

local Bar = LibStub('Classy-1.0'):New('Frame')
local TCFB = select(2, ...)
TCFB.Bar = Bar

local frames = {}

local function frame_Create(id, o)
	local frame = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)

	frame:SetAttribute('id', id)
	frame:SetFrameRef("uiParent", UIParent)

	frame:SetAttribute('_childupdate', [[
		self:SetAttribute(scriptid, message)
	]])

	frame:SetAttribute('_onstate-main', [[
		self:RunAttribute('lodas', string.split(',', self:GetAttribute('loadAttributes')))
	]])

	frame:SetAttribute('_onstate-lock', [[
		if newstate then
			self:GetFrameRef('dragFrame'):Hide()
		else
			self:GetFrameRef('dragFrame'):Show()
		end
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
			self:CallMethod('SaveAttribute', atr, state, newVal)
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
		self:GetFrameRef('dragFrame'):SetScale(newstate)
	]])

	frame:SetAttribute('_onstate-point', [[
		local point, xOff, yOff = string.split(';', newstate)
		self:ClearAllPoints()
		self:SetPoint(point, self:GetParent(), point, xOff, yOff)
	]])

	return frame
end

function Bar:New(frameId, settings)
	local f = self:Bind(frame_Create(frameId))
	f:SetAttribute('loadAttributes', 'show,scale,alpha,point')
	f:SetFrameRef('dragFrame', TCFB.DragFrame:New(f))
	f.sets = settings

	f:LoadAttributes()
	TCFB.MajorTom:addFrame(f)
	frames[frameId] = f

	return f
end

function Bar:Get(frameId)
	return frames[frameId]
end


--attributes
function Bar:SetAtr(attribute, newValue, state)
	state = state or self:GetAttribute('state-main')

	local oldValue = self:GetAtr(attribute, state)
	if oldValue ~= newValue then
		self:SetAttribute(attribute .. '-' .. state, newValue)
		self:SaveAttribute(attribute, newValue, state)
		
		if state == self:GetAttribute('state-main') then
			self:SetAttribute('state-' .. attribute, newValue)
		end
	end
end

function Bar:GetAtr(attribute, state)
	state = state or self:GetAttribute('state-main')

	local v = self:GetAttribute(attribute .. '-' .. state)
	if v == nil then
		v = self:GetAttribute(attribute .. '-default')
	end
	return v
end

function Bar:SaveAttribute(attribute, value, state)
	state = state or self:GetAttribute('state-main')

	local stateSets = self.sets[state]
	if not stateSets then
		self.sets[state] = {[attribute] = value}
	end
	stateSets[attribute] = value
end

function Bar:LoadAttributes()
	for state, attributes in pairs(self.sets) do
		for attribute, value in pairs(attributes) do
			self:SetAtr(attribute, value, state)
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
		self:SetAtr('point', string.join(';', point, x, y))
		return true
	end
end

function Bar:Stick()
	self:ClearAnchor()

	--only do sticky code if the alt key is not currently down
	if not IsAltKeyDown() then
		-- --try to stick to a bar, then try to stick to a screen edge
		-- for _, f in self:GetAll() do
			-- if f ~= self then
				-- local point = FlyPaper.Stick(self, f, self.stickyTolerance)
				-- if point then
					-- self:SetAnchor(f, point)
					-- break
				-- end
			-- end
		-- end

		-- if not self.sets.anchor then
			self:StickToEdge()
		-- end
	end

	self:SavePosition()
	self.drag:UpdateColor()
end

-- function Bar:Reanchor()
	-- local f, point = self:GetAnchor()
	-- if not(f and FlyPaper.StickToPoint(self, f, point)) then
		-- self:ClearAnchor()
		-- if not self:Reposition() then
			-- self:ClearAllPoints()
			-- self:SetPoint('CENTER')
		-- end
	-- else
		-- self:SetAnchor(f, point)
	-- end
	-- self.drag:UpdateColor()
-- end

function Bar:SetAnchor(anchor, point)
--	self.sets.anchor = anchor.id .. point
end

function Bar:ClearAnchor()
--	self.sets.anchor = nil
end

function Bar:GetAnchor()
	-- local anchorString = self.sets.anchor
	-- if anchorString then
		-- local pointStart = #anchorString - 1
		-- return self:Get(anchorString:sub(1, pointStart - 1)), anchorString:sub(pointStart)
	-- end
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

function Bar:SavePosition()
	self:SetAtr('point', string.join(';', self:GetRelPosition()))
	self:SetUserPlaced(true)
end

--place the frame at it's saved position
-- function Bar:Reposition()
	-- self:Rescale()

	-- local sets = self.sets
	-- local point, x, y = sets.point, sets.x, sets.y

	-- if point then
		-- self:ClearAllPoints()
		-- self:SetPoint(point, x, y)
		-- self:SetUserPlaced(true)
		-- return true
	-- end
-- end
