--[[
	majorTom.lua
		this is a long way to go for a bowie reference
--]]

local controller = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
controller:SetAllPoints(controller:GetParent())
controller:SetFrameRef('SecureStateDriverManager', SecureStateDriverManager)

--main controller state
controller:SetAttribute('_onstate-groundControl', [[
	local prevstate = self:GetAttribute('state-main')
	local newstate = self:GetAttribute('state-majorTom') or newstate

	if prevstate ~= newstate then
		self:SetAttribute('state-main', newstate)
	end
]])

--override state
controller:SetAttribute('_onstate-majorTom', [[
	local prevstate = self:GetAttribute('state-main')
	local newstate = newstate or self:GetAttribute('state-groundControl')

	if prevstate ~= newstate then
		self:SetAttribute('state-main', newstate)
	end
]])

--current state (majorTom or groundControl)
controller:SetAttribute('_onstate-main', [[
	self:ChildUpdate('state-main', newstate)
]])

--lock state
controller:SetAttribute('_onstate-lock', [[
	self:ChildUpdate('state-lock', newstate)
]])

--adds the given frame to control by majorTom
controller:SetAttribute('addFrame', [[
	local f = self:GetFrameRef('addFrame')

	if not myFrames then
		myFrames = table.new()
	end
	myFrames[f:GetAttribute('id')] = f


	f:SetParent(self)
	f:SetAttribute('state-main', self:GetAttribute('state-main'))
	f:SetAttribute('state-lock', self:GetAttribute('state-lock'))
	f:SetAttribute('state-destroy', nil)
]])

controller:SetAttribute('delFrame', [[
	local f = self:GetFrameRef('delFrame')
	if myFrames then
		myFrames[f:GetAttribute('id')] = nil
	end

	f:SetAttribute('state-destroy', true)
	f:SetParent(nil)
	f:Hide()
]])

controller:SetAttribute('placeFrame', [[
	local frameId, point, relFrameId, relPoint, xOff, yOff = ...
	local frame = myFrames[tonumber(frameId) or frameId]
	local relFrame =  myFrames[tonumber(relFrameId) or relFrameId]

	if frame and relFrame then
		frame:SetPoint(point, relFrame, relPoint, xOff, yOff)
		return true
	end
	return false
]])


--[[ state driver stuff (necessary so that I can remap frame state drivers in combat ]]--

-- Register a frame attribute to be set automatically with changes in game state
controller:SetAttribute('RegisterAttributeDriver', [[
	local SecureStateDriverManager = self:GetFrameRef('SecureStateDriverManager')
	local frameId, attribute, values = ...
	local frame = myFrames[tonumber(frameId) or frameId]
	
    if ( attribute and values and attribute:sub(1, 1) ~= "_" ) then
        SecureStateDriverManager:SetAttribute("setframe", frame);
        SecureStateDriverManager:SetAttribute("setstate", attribute.." "..values);
    end
]])

-- Unregister a frame from the state driver manager.
controller:SetAttribute('UnregisterAttributeDriver', [[
	local SecureStateDriverManager = self:GetFrameRef('SecureStateDriverManager')
	local frameId, attribute = ...
	local frame = myFrames[tonumber(frameId) or frameId]
	
    if ( attribute ) then
        SecureStateDriverManager:SetAttribute("setframe", frame);
        SecureStateDriverManager:SetAttribute("setstate", attribute);
    else
        SecureStateDriverManager:SetAttribute("delframe", frame);
    end
]])

-- Bridge functions for compatibility
controller:SetAttribute('RegisterStateDriver', [[
	local frameId, state, values = ...
    return self:RunAttribute('RegisterAttributeDriver', frameId, 'state-'..state, values);
]])

controller:SetAttribute('UnregisterStateDriver', [[
	local frameId, state = ...
    return self:RunAttribute('UnregisterAttributeDriver', frameId, 'state-'..state);
]])

local TCFB = select(2, ...)
TCFB.MajorTom = {
	--add frame to state control
	addFrame = function(self, frame)
		controller:SetFrameRef('addFrame', frame)
		controller:Execute([[ self:RunAttribute('addFrame') ]])
	end,

	--remove frame from state control
	removeFrame = function(self, frame)
		controller:SetFrameRef('delFrame', frame)
		controller:Execute([[ self:RunAttribute('delFrame') ]])
	end,

	--updates the state driver for groundControl
	setStateDriver = function(self, values)
		self.stateDriver = stateDriver
		RegisterStateDriver(controller, 'groundControl', values)
	end,

	getStateDriver = function(self, values)
		return self.stateDriver
	end,

	--updates the override state for groundControl (majorTom)
	setOverrideState = function(self, state)
		controller:SetAttribute('state-majorTom', state)
	end,

	getState = function(self)
		return controller:GetAttribute('state-main')
	end,

	--enables|disables the lock state
	setLock = function(self, enable)
		controller:SetAttribute('state-lock', enable and true or false)
	end,

	getLock = function(self)
		return controller:GetAttribute('state-lock')
	end,
}