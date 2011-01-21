--[[
	bagBar.lua
		A bar that contains the menu bar bag buttons
--]]

local TCFB = select(2, ...)
local BagBar = LibStub('Classy-1.0'):New('Frame', TCFB.ButtonBar)
TCFB.BagBar = BagBar

--clean up the main bag button + create a square keyring
do
	local NT_RATIO = 64/37

	local function itemButton_Resize(b, size)
		b:SetSize(size, size)
		b:GetNormalTexture():SetSize(size * NT_RATIO, size * NT_RATIO)

		local count = _G[b:GetName() .. 'Count']
		count:SetFontObject('NumberFontNormalSmall')
		count:SetPoint('BOTTOMRIGHT', 0, 2)

		_G[b:GetName() .. 'Stock']:SetFontObject('NumberFontNormalSmall')
		_G[b:GetName() .. 'Stock']:SetVertexColor(1, 1, 0)
	end

	local function keyRing_Create(name)
		local b = CreateFrame('CheckButton', name, UIParent, 'ItemButtonTemplate')
		b:RegisterForClicks('anyUp')
		b:Hide()

		b:SetScript('OnClick', function()
			if CursorHasItem() then
				PutKeyInKeyRing()
			else
				ToggleKeyRing()
			end
		end)

		b:SetScript('OnReceiveDrag', function()
			if CursorHasItem() then
				PutKeyInKeyRing()
			end
		end)

		b:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_LEFT')

			local color = HIGHLIGHT_FONT_COLOR
			GameTooltip:SetText(KEYRING, color.r, color.g, color.b)
			GameTooltip:AddLine()
		end)

		b:SetScript('OnLeave', function()
			GameTooltip:Hide()
		end)

		_G[b:GetName() .. 'IconTexture']:SetTexture([[Interface\ContainerFrame\KeyRing-Bag-Icon]])
		_G[b:GetName() .. 'IconTexture']:SetTexCoord(0, 0.9, 0.1, 1)

		itemButton_Resize(b, 30)
	end

	keyRing_Create('TCFBKeyringButton')
	itemButton_Resize(_G['MainMenuBarBackpackButton'], 30)
end


function BagBar:New(settings)
	return TCFB.ButtonBar['New'](self, 'bags', settings)
end

function BagBar:Create(frameId)
	local bar = TCFB.ButtonBar['Create'](self, frameId)

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

		if self:GetAttribute('state-showKeyring') then
			table.insert(myButtons, self:GetFrameRef('keyring'))
		else
			self:GetFrameRef('keyring'):Hide()
		end

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
		button:Show()

		return f
	end

	local addContainer = function(button)
		bar:SetFrameRef('addBag', wrapButton(button))
		bar:Execute([[ self:RunAttribute('addBag') ]])
	end

	local addKeyring = function(button)
		bar:SetFrameRef('keyring', wrapButton(button))
	end

	local addBackpack = function(button)
		bar:SetFrameRef('backpack', wrapButton(button))
	end

 	addBackpack(_G['MainMenuBarBackpackButton'])
	addKeyring(_G['TCFBKeyringButton'])
	for i = 1, NUM_BAG_SLOTS do
		addContainer(_G[string.format('CharacterBag%dSlot', 4 - i)])
	end

	return bar
end

function BagBar:SetShowKeyring(enable)
	self:Set('showKeyring', enable)
	bar:Execute([[ self:RunAttribute('refreshButtons') ]])
	bar:Execute([[ self:RunAttribute('layout') ]])
end

function BagBar:SetOneBag(enable)
	self:Set('oneBag', enable)
	bar:Execute([[ self:RunAttribute('refreshButtons') ]])
	bar:Execute([[ self:RunAttribute('layout') ]])
end