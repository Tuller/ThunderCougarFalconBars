local AddonName, Addon = ...
local TCFB = LibStub('AceAddon-3.0'):NewAddon(Addon, AddonName, 'AceEvent-3.0', 'AceConsole-3.0')

function TCFB:OnInitialize()
	self:HideBlizzard()
	self:LoadSlashCommands()
end

function TCFB:OnEnable()
	self.MajorTom:SetStateDriver('[mod:alt]alt;[mod:ctrl];ctrl;default')
	self.MajorTom:SetLock(false)
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
			TCFB.MajorTom:SetLock(not TCFB.MajorTom:GetLock())
		elseif cmd == 'create' then
			TCFB:Create(select(2, unpack(info)))
		elseif cmd == 'destroy' then
			TCFB:Destroy(select(2, unpack(info)))
		end
	end
end