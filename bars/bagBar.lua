local TCFB = select(2, ...)
local BagBar = LibStub('Classy-1.0'):New('Frame', TCFB.Bar)
TCFB.BagBar = BagBar

local BAR_ATTRIBUTES = {
	'enable',
	'show',
	'scale',
	'alpha',
	'point',
	'anchor',
	'columns',
	'spacing',
	'padW',
	'padH'
}

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
	return self:super('New', 'bags', settings)
end

function BagBar:Create(frameId)
	local bar = self:super('Create', frameId)
	
	bar:SetAttribute('myAttributes', table.concat(BAR_ATTRIBUTES, ','))
	
	bar:SetAttribute('_onstate-main', [[
		self:RunAttribute('lodas', string.split(',', self:GetAttribute('myAttributes')))
		self:RunAttribute('layout')
	]])
	
	bar:SetAttribute('_onstate-oneBag', [[
		needsLayout = true
	]])
	
	bar:SetAttribute('_onstate-showKeyring', [[
		needsLayout = true
	]])
	
	bar:SetAttribute('_onstate-columns', [[
		needsLayout = true
	]])
	
	bar:SetAttribute('_onstate-spacing', [[
		needsLayout = true
	]])
	
	bar:SetAttribute('_onstate-padW', [[
		needsLayout = true
	]])
	
	bar:SetAttribute('_onstate-padH', [[
		needsLayout = true
	]])
	
	bar:SetAttribute('reloadButtons', [[
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
	]])
	
	bar:Execute([[ SPACING_OFFSET = 2; PADDING_OFFSET = 4 ]])

	bar:SetAttribute('layout', [[
		if not needsLayout then return end
		
		self:RunAttribute('reloadButtons')

		local numButtons = #myButtons
		local cols = min(self:GetAttribute('state-columns'), numButtons)
		local rows = ceil(numButtons / cols)
		local spacing = self:GetAttribute('state-spacing') + SPACING_OFFSET
		local pW = self:GetAttribute('state-padW') + PADDING_OFFSET 
		local pH = self:GetAttribute('state-padH') + PADDING_OFFSET

		local b = myButtons[1]
		local w = b:GetWidth() + spacing
		local h = b:GetHeight() + spacing
		
		for i = 1, numButtons do
			local b = myButtons[i]
			local col = (i-1) % cols
			local row = ceil(i / cols) - 1
			
			b:ClearAllPoints()
			b:SetPoint('TOPLEFT', self, 'TOPLEFT', w*col + pW, -(h*row + pH))
			b:Show()
		end

		self:SetWidth(max(w*cols - spacing + pW*2, 8))
		self:SetHeight(max(h*rows - spacing + pH*2, 8))
		
		needsLayout = nil
	]])
	
	--add button method
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
	
	local addKeyring = function(button)
		bar:SetFrameRef('keyring', button)
		button:SetParent(bar)
	end
	
	local addBackpack = function(button)
		bar:SetFrameRef('backpack', button)
		button:SetParent(bar)
	end
	
 	addBackpack(_G['MainMenuBarBackpackButton'])
	addKeyring(_G['TCFBKeyringButton'])
	for i = 1, NUM_BAG_SLOTS do
		addContainer(_G[string.format('CharacterBag%dSlot', 4 - i)])
	end
	
	bar:SetAttribute('state-showKeyring', true)

	return bar
end