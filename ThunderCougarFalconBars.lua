local name, addonTable = ...

TCFB = setmetatable({}, {__index = addonTable})

TCFB.SetLock = function(self, enable)
	self.MajorTom:setLock(enable)
end

do
	TCFB.MajorTom:setStateDriver('[mod:alt]alt;default')
	TCFB.MajorTom:setLock(false)

	local bar = TCFB.Bar:New('waffles', {
		default = {
			show = true,
			alpha = 1,
			scale = 1,
			point = 'CENTER;0;0',
		},
		alt = {
			show = false,
			alpha = 0.5,
			scale = 2,
			point = 'TOPLEFT;0;0',
		}
	})
	bar:SetSize(256, 64)

	local bg = bar:CreateTexture(nil, 'BACKGROUND')
	bg:SetAllPoints(bar)
	bg:SetTexture(0, 0.5, 0, 0.5)
	bar.bg = bg
end