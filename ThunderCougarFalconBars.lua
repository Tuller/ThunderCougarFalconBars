local name, addonTable = ...

TCFB = setmetatable({}, {__index = addonTable})

TCFB.ToggleLock = function(self)
	self.MajorTom:setLock(not self.MajorTom:getLock())
end

TCFB.Create = function(self, id)
	local id = tonumber(id) or id

	local bar = TCFB.Bar:New(id, {
		default = {
			enable = true,
			show = true,
			alpha = 1,
			scale = 1,
			point = ('CENTER;0;%d'):format((id - 1) * -36),
			anchor = false,
			autoFadeDriver = '[mod]show;hide',
		},
		alt = {
			enable = id < 4,
			alpha = 0.5,
			scale = 1.5,
			point = ('TOPLEFT;0;%d'):format((id - 1) * -36),
			anchor = false,
			autoFadeDriver = '[mod:shift]hide;show',
		}
	})
	bar:SetSize(400, 36)
end

TCFB.Destroy = function(self, id)
	TCFB.Bar:GetBar(id):Free()
end

--add slash commands
SLASH_ThunderCougarFalconBars1 = '/thundercougarfalconbars'
SLASH_ThunderCougarFalconBars2 = '/tcfb'
SLASH_ThunderCougarFalconBars3 = '/tc'
SlashCmdList['ThunderCougarFalconBars'] = function(msg)
	local info = {string.split(' ', msg:lower())}
	local cmd = info[1]

	if cmd == 'lock' then
		TCFB:ToggleLock()
	elseif cmd == 'create' then
		TCFB:Create(select(2, unpack(info)))
	elseif cmd == 'destroy' then
		TCFB:Destroy(select(2, unpack(info)))
	end
end

do
	TCFB.MajorTom:setStateDriver('[mod:alt]alt;default')
	TCFB.MajorTom:setLock(false)

	for id = 1, 4 do
		TCFB:Create(id)
	end
end