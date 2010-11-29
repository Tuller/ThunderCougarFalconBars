local TCFB = LibStub('AceAddon-3.0'):NewAddon('ThunderCougarFalconBars', 'AceEvent-3.0', 'AceConsole-3.0')
--inject super addon powers
do
	local name, addonTable = ...
	for k, v in pairs(addonTable) do
		TCFB[k] = v
	end
end

function TCFB:OnEnable()
	self:HideBlizzard()
	self:LoadSlashCommands()
	
	self.MajorTom:setStateDriver('[mod:alt]alt;[mod:ctrl];ctrl;default')
	self.MajorTom:setLock(false)
	
	self.ClassBar:New{
		default = {
			enable = true,
			show = true,
			alpha = 1,
			scale = 1,
			point = 'BOTTOM;0;74',
			anchor = false,
			columns = 12,
			padding = 0,
			spacing = 4,
			padW = 0,
			padH = 0,
		},	
	}
	
	self.MenuBar:New{
		default = {
			enable = true,
			show = true,
			alpha = 1,
			scale = 1,
			point = 'BOTTOMRIGHT;-200;0',
			anchor = false,
			columns = 12,
			padding = 0,
			spacing = 0,
			padW = 0,
			padH = 0,
		},		
	}
	
	self.PetBar:New{
		default = {
			enable = true,
			show = true,
			alpha = 1,
			scale = 1,
			point = 'BOTTOM;0;37',
			anchor = false,
			columns = 10,
			padding = 0,
			spacing = 0,
			padW = 0,
			padH = 0,
		},		
	}
	
	self.BagBar:New{
		default = {
			enable = true,
			show = true,
			alpha = 1,
			scale = 1,
			point = 'BOTTOMRIGHT;0;0',
			anchor = false,
			columns = 10,
			padding = 0,
			spacing = 0,
			padW = 0,
			padH = 0,
			oneBag = false,
			showKeyring = true,
		},		
		alt = {
			oneBag = true,
			showKeyring = false,
		}
	}
	
	for id = 1, 2 do
		self.ActionBar:New(id, {
			default = {
				enable = true,
				show = true,
				alpha = 1,
				scale = 1,
				point = 'BOTTOM;0;0',
				anchor = false,
				columns = 12,
				padding = 0,
				spacing = 0,
				padW = 0,
				padH = 0,
			},		
		})
	end
end

--hide the blizzard ui
function TCFB:HideBlizzard()
	local noop = Multibar_EmptyFunc
	MultiActionBar_Update = noop
	MultiActionBar_UpdateGrid = noop
	ShowBonusActionBar = noop

	--hack, to make sure the seat indicator is placed in the right spot
	if not _G['VehicleSeatIndicator']:IsUserPlaced() then
		_G['VehicleSeatIndicator']:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", 0, -13)
	end

	UIPARENT_MANAGED_FRAME_POSITIONS['MultiBarRight'] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS['MultiBarLeft'] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS['MultiBarBottomLeft'] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS['MultiBarBottomRight'] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS['MainMenuBar'] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS['ShapeshiftBarFrame'] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS['PossessBarFrame'] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS['PETACTIONBAR_YPOS'] = nil

	MainMenuBar:UnregisterAllEvents()
	MainMenuBar:Hide()

	MainMenuBarArtFrame:UnregisterEvent('PLAYER_ENTERING_WORLD')
--	MainMenuBarArtFrame:UnregisterEvent('BAG_UPDATE') --needed to display stuff on the backpack button
	MainMenuBarArtFrame:UnregisterEvent('ACTIONBAR_PAGE_CHANGED')
--	MainMenuBarArtFrame:UnregisterEvent('KNOWN_CURRENCY_TYPES_UPDATE') --needed to display the token tab
--	MainMenuBarArtFrame:UnregisterEvent('CURRENCY_DISPLAY_UPDATE')
	MainMenuBarArtFrame:UnregisterEvent('ADDON_LOADED')
	MainMenuBarArtFrame:UnregisterEvent('UNIT_ENTERING_VEHICLE')
	MainMenuBarArtFrame:UnregisterEvent('UNIT_ENTERED_VEHICLE')
	MainMenuBarArtFrame:UnregisterEvent('UNIT_EXITING_VEHICLE')
	MainMenuBarArtFrame:UnregisterEvent('UNIT_EXITED_VEHICLE')
	MainMenuBarArtFrame:Hide()

	MainMenuExpBar:UnregisterAllEvents()
	MainMenuExpBar:Hide()

	ShapeshiftBarFrame:UnregisterAllEvents()
	ShapeshiftBarFrame:Hide()

	BonusActionBarFrame:UnregisterAllEvents()
	BonusActionBarFrame:Hide()

	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	else
		hooksecurefunc('TalentFrame_LoadUI', function()
			PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
		end)
	end
end

--add slash commands
function TCFB:LoadSlashCommands()
	SLASH_ThunderCougarFalconBars1 = '/thundercougarfalconbars'
	SLASH_ThunderCougarFalconBars2 = '/tcfb'
	SLASH_ThunderCougarFalconBars3 = '/tc'
	SlashCmdList['ThunderCougarFalconBars'] = function(msg)
		local info = {string.split(' ', msg:lower())}
		local cmd = info[1]

		if cmd == 'lock' then
			TCFB.MajorTom:setLock(not TCFB.MajorTom:getLock())
		elseif cmd == 'create' then
			TCFB:Create(select(2, unpack(info)))
		elseif cmd == 'destroy' then
			TCFB:Destroy(select(2, unpack(info)))
		end
	end
end