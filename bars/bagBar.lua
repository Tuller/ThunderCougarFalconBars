--[[
	bagBar.lua
		A bar that contains the menu bar bag buttons
--]]

local AddonName, Addon = ...
local BagBar = LibStub('Classy-1.0'):New('Frame', Addon.ButtonBar); Addon.BagBar = BagBar

function BagBar:New(settings)
	return BagBar.Super('New', self, 'bags', settings)
end

function BagBar:Create(frameId)
	local bar = BagBar.Super('Create', self, frameId)

	bar:SetAttribute('myAttributes', bar:GetAttribute('myAttributes') .. ',oneBag,showKeyring')

	bar:SetAttribute('_onstate-main', [[
		self:RunAttribute('lodas', string.split(',', self:GetAttribute('myAttributes')))
		self:RunAttribute('refreshButtons')
		self:RunAttribute('layout')
	]])

	bar:SetAttribute('_onstate-oneBag', [[
		needsButtonRefresh = true
		needsLayout = true
	]])

	bar:SetAttribute('_onstate-showKeyring', [[
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

	local wrapButton = function(button)
		local f = CreateFrame('Frame', nil, bar, 'SecureHandlerBaseTemplate')
		f:SetSize(button:GetSize())

		button:SetParent(f)
		button:ClearAllPoints()
		button:SetPoint('CENTER', f)
		-- button:Show()

		return f
	end

	local addContainer = function(button)
		bar:SetFrameRef('addBag', bar:SecureWrap(button))
		bar:Execute([[ self:RunAttribute('addBag') ]])
	end

	local addBackpack = function(button)
		bar:SetFrameRef('backpack', bar:SecureWrap(button))
	end
	
 	addBackpack(_G['MainMenuBarBackpackButton'])
	
	for i = 1, NUM_BAG_SLOTS do
		addContainer(_G[string.format('CharacterBag%dSlot', 4 - i)])
	end

	return bar
end

function BagBar:SetOneBag(enable)
	self:Set('oneBag', enable)
	bar:Execute([[ self:RunAttribute('refreshButtons') ]])
	bar:Execute([[ self:RunAttribute('layout') ]])
end