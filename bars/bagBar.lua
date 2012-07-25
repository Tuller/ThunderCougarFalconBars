--[[
	bagBar.lua
		A bar that contains the menu bar bag buttons
--]]

local AddonName, Addon = ...
local BagBar = Addon:NewFrameClass('Frame', Addon.ButtonBar); Addon.BagBar = BagBar

BagBar.BAR_ATTRIBUTES = Addon.Utility:ConcatArrays(Addon.ButtonBar.BAR_ATTRIBUTES, { 'oneBag' })

function BagBar:New(settings)
	return BagBar.Super('New', self, 'bags', settings)
end

function BagBar:Create(frameId)
	local bar = BagBar.Super('Create', self, frameId)
	
	bar:SetAttribute('postMain', [[
		needsButtonRefresh = true
		
		self:RunAttribute('refreshButtons')
		self:RunAttribute('layout')
	]])
	
	bar:SetAttribute('_onstate-oneBag', [[
		needsButtonRefresh = true
		needsLayout = true
	]])
	
	bar:Execute([[
		SPACING_OFFSET = 2
		PADW_OFFSET = 4
		PADH_OFFSET = 4
	]])

	--adjust what buttons are visible based on showKeyring/oneBag settings
	bar:SetAttribute('refreshButtons', [[
		if not needsButtonRefresh then return end

		myButtons = myButtons or table.new()
		wipe(myButtons)

		if not self:GetAttribute('state-oneBag') then
			for i, bag in ipairs(myBags) do
				table.insert(myButtons, bag)
			end
		else
			for i, bag in ipairs(myBags) do
				bag:Hide()
			end
		end

		table.insert(myButtons, self:GetFrameRef('backpack'))

		needsButtonRefresh = nil
	]])

	--add bag method, replaces the add button method
	bar:SetAttribute('addBag', [[
		local button = self:GetFrameRef('addBag')
		
		if button then
			myBags = myBags or table.new()
			table.insert(myBags, button)
			button:SetParent(self)
		end
	]])

	local addContainer = function(button)
		bar:SetFrameRef('addBag', button)
		bar:Execute([[ self:RunAttribute('addBag') ]])
	end

	local addBackpack = function(button)
		bar:SetFrameRef('backpack', button)
		bar:Execute([[ self:GetFrameRef('backpack'):SetParent(self) ]])
	end
	
 	addBackpack(_G['MainMenuBarBackpackButton'])
	
	for i = 1, NUM_BAG_SLOTS do
		addContainer(_G[string.format('CharacterBag%dSlot', NUM_BAG_SLOTS - i)])
	end

	return bar
end

function BagBar:SetOneBag(enable)
	self:Set('oneBag', enable)
	bar:Execute([[ self:RunAttribute('refreshButtons') ]])
	bar:Execute([[ self:RunAttribute('layout') ]])
end