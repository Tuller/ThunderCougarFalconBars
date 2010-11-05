--[[
	majorTom.lua
--]]

local MajorTom = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate'); MajorTom:SetAllPoints(UIParent)

--main controller state
MajorTom:SetAttribute('_onstate-majorTom', [[ 
	self:SetAttribute('currentState') = self:GetAttribute('state-groundControl') or newstate
	self:RunAttribute('updateFrames', self:GetAttribute('currentState'))
]])

--override state
MajorTom:SetAttribute('_onstate-groundControl', [[ 
	self:SetAttribute('currentState') = newstate or self:GetAttribute('state-groundControl')
	self:RunAttribute('updateFrames', self:GetAttribute('currentState'))
]])

--update all frames
MajorTom:SetAttribute('updateFrames' [[
	local currentState = ...
	if myFrames then
		for _, frame in pairs(myFrames) do
			self:RunAttribute('updateFrame', frame, currentState)
		end
	end
]])

--updates the given frame (parameters: frame, currentState)
MajorTim:SetAttribute('updateFrame', [[
	local frame, currentState = ...
	frame:RunAttribute('update', currentState)
]])

--adds the given frame to control by majorTom
MajorTom:SetAttribute('addFrame', [[
	local newFrame = ...
		
	if not myFrames then myFrames = table.new(...) end
	myFrames[newFrame:GetAttribute('id')] = newFrame
	newFrame:SetParent(self)

	self:RunAttribute('updateFrame', newFrame, self:GetAttribute('currentState'))
]])

--removes the frame from control by majorTom
MajorTom:SetAttribute('delFrame', [[
	local delFrame = ...
	if myFrames then 
		myFrames[delFrame:GetAttribute('id')] = nil
	end
]])

--add frame to state control
function MajorTom:AddFrame(frame)
	self:SetFrameRef('addFrame', frame)
	self:Execute([[ self:RunAttribute('addFrame', self:GetFrameRef('addFrame')) ]])
end

--remove frame from state control
function MajorTom:RemoveFrame(frame)
	self:SetFrameRef('delFrame', frame)
	self:Execute([[ self:RunAttribute('delFrame', self:GetFrameRef('delFrame')) ]])
end

--updates the state driver for majorTom
function MajorTom:SetStateDriver(values)
	RegisterStateDriver(self, 'state-majorTom', values)
--	self:SetAttribute('state-majorTom', SecureCmdOptionParse(values))
end

--updates the override state for majorTom (groundControl)
function MajorTom:SetOverrideState(state)
	self:SetAttribute('state-groundControl', state)
end

do
	local _, TCFB = ...
	TCFB.MajorTom = MajorTom
end