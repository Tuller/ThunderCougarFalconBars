local AddonName, Addon = ...
local TCFB = LibStub('AceAddon-3.0'):NewAddon(Addon, AddonName, 'AceEvent-3.0', 'AceConsole-3.0')

function TCFB:OnEnable()
	self:HideBlizzard()
	--self:LoadSlashCommands()
	
	self.MajorTom:SetStateDriver('[mod:alt]alt;[mod:ctrl];ctrl;default')
	self.MajorTom:SetLock(false)

	if self.StanceBar then
		self.StanceBar:New{
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
	end
	
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

	for id = 1, 12 do
		self.ActionBar:New(id, {
			default = {
				enable = true,
				show = true,
				alpha = 1,
				scale = 1,
				point = string.format('BOTTOM;0;%d', 40 * (id - 1)),
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
	_G['ActionBarController']:UnregisterAllEvents()
	_G['MainMenuExpBar']:UnregisterAllEvents()
	_G['OverrideActionBar']:UnregisterAllEvents()
	
	_G['MainMenuBarArtFrame']:UnregisterAllEvents()
	_G['MainMenuBarArtFrame']:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
	_G['MainMenuBarArtFrame']:RegisterEvent('UNIT_LEVEL')
	
	_G['MainMenuBar']:Hide()
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
			TCFB.MajorTom:SetLock(not TCFB.MajorTom:getLock())
		elseif cmd == 'create' then
			TCFB:Create(select(2, unpack(info)))
		elseif cmd == 'destroy' then
			TCFB:Destroy(select(2, unpack(info)))
		end
	end
end