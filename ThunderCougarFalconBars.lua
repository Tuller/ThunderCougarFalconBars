local name, addonTable = ...

TCFB = setmetatable({}, {__index = addonTable})

TCFB.ToggleLock = function(self)
	self.MajorTom:setLock(not self.MajorTom:getLock())
end

--add slash commands
SLASH_ThunderCougarFalconBars1 = '/thundercougarfalconbars'
SLASH_ThunderCougarFalconBars2 = '/tcfb'
SLASH_ThunderCougarFalconBars3 = '/tc'
SlashCmdList['ThunderCougarFalconBars'] = function(msg)
	local cmd, args = string.split(' ', msg:lower())
	if cmd == 'lock' then
		TCFB:ToggleLock()
	end
end

do
	TCFB.MajorTom:setStateDriver('[mod:alt]alt;default')
	TCFB.MajorTom:setLock(false)

	for id = 1, 4 do
		local bar = TCFB.Bar:New(id, {
			default = {
				enable = true,
				show = true,
				alpha = 1,
				scale = 1,
				point = 'CENTER;0;0',
				anchor = false,
			},
			alt = {
				enable = id < 4,
				alpha = 0.5,
				scale = 1.5,
				point = 'TOPLEFT;0;0',
				anchor = false,
			}
		})
		bar:SetSize(400, 36)

		local bg = bar:CreateTexture(nil, 'BACKGROUND')
		bg:SetAllPoints(bar)
		bg:SetTexture(0, 0.5, 0, 0.5)
		bar.bg = bg
	end
end