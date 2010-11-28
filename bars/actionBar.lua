--[[
	actionBar.lua
		A bar that contains actionButtons
--]]

local TCFB = select(2, ...)
local ActionBar = LibStub('Classy-1.0'):New('Frame', TCFB.ButtonBar)
TCFB.ActionBar = ActionBar


--[[ Constructor Code ]]--

--metatable magic.  Basically this says, 'create a new table for this index'
--I do this so that I only create page tables for classes the user is actually playing
ActionBar.defaultOffsets = {
	__index = function(t, i)
		t[i] = {}
		return t[i]
	end
}

--metatable magic.  Basically this says, 'create a new table for this index, with these defaults'
--I do this so that I only create page tables for classes the user is actually playing
ActionBar.mainbarOffsets = {
	__index = function(t, i)
		local pages = {
			['[bar:2]'] = 1,
			['[bar:3]'] = 2,
			['[bar:4]'] = 3,
			['[bar:5]'] = 4,
			['[bar:6]'] = 5,
		}

		if i == 'DRUID' then
--			pages['[bonusbar:1,stealth]'] = 5
			pages['[bonusbar:1]'] = 6
			pages['[bonusbar:2]'] = 7
			pages['[bonusbar:3]'] = 8
			pages['[bonusbar:4]'] = 9
		elseif i == 'WARRIOR' then
			pages['[bonusbar:1]'] = 6
			pages['[bonusbar:2]'] = 7
			pages['[bonusbar:3]'] = 8
		elseif i == 'PRIEST' then
			pages['[bonusbar:1]'] = 6
		elseif i == 'ROGUE' then
			pages['[bonusbar:1]'] = 6 --stealth
			pages['[bonusbar:2]'] = 6 --shadowdance
--[[
		elseif i == 'WARLOCK' then
			pages['[form:2]'] = 6 --demon form, need to watch this to make sure blizzard doesn't change the page
--]]
		end

		t[i] = pages
		return pages
	end
}

--this is the set of conditions used for paging, in order of evaluation
ActionBar.conditions = {
	'[mod:SELFCAST]',
	'[mod:alt,mod:ctrl,mod:shift]',
	'[mod:alt,mod:ctrl]',
	'[mod:alt,mod:shift]',
	'[mod:ctrl,mod:shift]',
	'[mod:alt]',
	'[mod:ctrl]',
	'[mod:shift]',
	'[bar:2]',
	'[bar:3]',
	'[bar:4]',
	'[bar:5]',
	'[bar:6]',
	'[bonusbar:1,stealth]', --prowl
	'[bonusbar:1,form:3]', --vanish
	'[form:2]', --metamorphosis
	'[bonusbar:1]',
	'[bonusbar:2]',
	'[bonusbar:3]',
	'[bonusbar:4]',
	'[help]',
	'[harm]',
	'[noexists]'
}

ActionBar.class = select(2, UnitClass('player'))
local active = {}

function ActionBar:New(id, settings)
	local f = TCFB.ButtonBar['New'](self, id, settings)
	f.sets.pages = setmetatable(f.sets.pages, f.id == 1 and self.mainbarOffsets or self.defaultOffsets)

	f.pages = f.sets.pages[f.class]
	f.baseID = f:MaxLength() * (id-1)

	f:LoadStateController()
	f:LoadButtons()
	f:UpdateStateDriver()
	f:Layout()
	f:UpdateGrid()
	f:UpdateRightClickUnit()

	active[id] = f

	return f
end

--TODO: change the position code to be based more on the number of action bars
function ActionBar:GetDefaults()
	local defaults = {}
	defaults.point = 'BOTTOM'
	defaults.x = 0
	defaults.y = 40*(self.id-1)
	defaults.pages = {}
	defaults.spacing = 4
	defaults.padW = 2
	defaults.padH = 2
	defaults.numButtons = self:MaxLength()

	return defaults
end

function ActionBar:Free()
	active[self.id] = nil
	self.super.Free(self)
end


--[[ button stuff]]--

function ActionBar:LoadButtons()
	for i = 1, self:NumButtons() do
		local b = ActionButton:New(self.baseID + i)
		if b then
			b:SetParent(self.header)
			self.buttons[i] = b
		else
			break
		end
	end
	self:UpdateActions()
end

function ActionBar:AddButton(i)
	local b = ActionButton:New(self.baseID + i)
	if b then
		self.buttons[i] = b
		b:SetParent(self.header)
		b:LoadAction()
		self:UpdateAction(i)
		self:UpdateGrid()
	end
end

function ActionBar:RemoveButton(i)
	local b = self.buttons[i]
	self.buttons[i] = nil
	b:Free()
end


--[[ Paging Code ]]--

function ActionBar:SetPage(condition, page)
	self.pages[condition] = page
	self:UpdateStateDriver()
end

function ActionBar:GetPage(condition)
	return self.pages[condition]
end

--note to self:
--if you leave a ; on the end of a statebutton string, it causes evaluation issues, especially if you're doing right click selfcast on the base state
function ActionBar:UpdateStateDriver()
--	UnregisterStateDriver(self.header, 'page', 0)

	local header = ''
	for state,condition in ipairs(self.conditions) do
		--possess bar: special case
		if condition == POSSESSED_CONDITIONAL then
			if self:IsPossessBar() then
				header = header .. condition .. 'possess;'
			end
		elseif self:GetPage(condition) then
			header = header .. condition .. 'S' .. state .. ';'
		end
	end

	if header ~= '' then
		RegisterStateDriver(self.header, 'page', header .. 0)
	end

	self:UpdateActions()
	self:RefreshActions()
end

local function ToValidID(id)
	return (id - 1) % MAX_BUTTONS + 1
end

--updates the actionID of a given button for all states
function ActionBar:UpdateAction(i)
	local b = self.buttons[i]
	local maxSize = self:MaxLength()

	for state,condition in ipairs(self.conditions) do
		local page = self:GetPage(condition)
		local id = page and ToValidID(b:GetAttribute('action--base') + (self.id + page - 1)*maxSize) or nil

		b:SetAttribute('action--S' .. state, id)
	end

	if self:IsPossessBar() and i <= NUM_POSSESS_BAR_BUTTONS then
		b:SetAttribute('action--possess', MAX_BUTTONS + i)
	else
		b:SetAttribute('action--possess', nil)
	end
end

--updates the actionID of all buttons for all states
function ActionBar:UpdateActions()
	local maxSize = self:MaxLength()

	for state,condition in ipairs(self.conditions) do
		local page = self:GetPage(condition)
		for i,b in pairs(self.buttons) do
			local page = self:GetPage(condition)
			local id = page and ToValidID(i + (self.id + page - 1)*maxSize) or nil

			b:SetAttribute('action--S' .. state, id)
		end
	end

	if self:IsPossessBar() then
		for i = 1, min(#self.buttons, NUM_POSSESS_BAR_BUTTONS) do
			self.buttons[i]:SetAttribute('action--possess', MAX_BUTTONS + i)
		end
		for i = NUM_POSSESS_BAR_BUTTONS + 1, #self.buttons do
			self.buttons[i]:SetAttribute('action--possess', nil)
		end
	else
		for _,b in pairs(self.buttons) do
			b:SetAttribute('action--possess', nil)
		end
	end
end

function ActionBar:LoadStateController()
	self:SetAttribute('_onstate-page', [[ control:ChildUpdate('action', newstate) ]])
end

function ActionBar:RefreshActions()
	local state = self:GetAttribute('state-page')
	if state then
		self:Execute(string.format([[ control:ChildUpdate('action', '%s') ]], state))
	else
		self:Execute([[ control:ChildUpdate('action', nil) ]])
	end
end

--Empty button display
function ActionBar:ShowGrid()
	self:Execute([[
		if myButtons then
			for i, b in pairs(myButtons) do
				b:SetAttribute('showgrid', b:GetAttribute('showgrid') + 1)
				b:CallMethod('UpdateGrid')
			end
		end
	]])
end

function ActionBar:HideGrid()
	self:Execute([[
		if myButtons then
			for i, b in pairs(myButtons) do
				b:SetAttribute('showgrid', b:GetAttribute('showgrid') - 1)
				b:CallMethod('UpdateGrid')
			end
		end
	]])
end

function ActionBar:UpdateGrid()
--	if Dominos:ShowGrid() then
		self:ShowGrid()
--	else
--		self:HideGrid()
--	end
end

--keybound support
function ActionBar:KEYBOUND_ENABLED()
	self:ShowGrid()
end

function ActionBar:KEYBOUND_DISABLED()
	self:HideGrid()
end


--right click targeting support
function ActionBar:UpdateRightClickUnit()
--	self.header:SetAttribute('*unit2', Dominos:GetRightClickUnit())
end

--utility functions
function ActionBar:ForAll(method, ...)
	for _,f in pairs(active) do
		f[method](f, ...)
	end
end