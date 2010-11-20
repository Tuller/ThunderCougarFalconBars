local name, addonTable = ...

TCFB = setmetatable({}, {__index = addonTable})

TCFB.SetLock = function(self, enable)
	self.MajorTom:setLock(enable)
end

do
	TCFB.MajorTom:setStateDriver('[mod:alt]alt;default')
	TCFB.MajorTom:setLock(false)

	local frame = TCFB.Frame:New('waffles', {
		default = {
			show = true,
			alpha = 1,
			scale = 1,
			point = 'CENTER,CENTER,0,0',
		},
		alt = {
			show = false,
			alpha = 0.5,
			scale = 2,
			point = 'TOPLEFT,TOPLEFT,0,0',
		}
	})
	frame:SetSize(256, 64)

	local bg = frame:CreateTexture(nil, 'BACKGROUND')
	bg:SetAllPoints(frame)
	bg:SetTexture(0, 0.5, 0, 0.5)
	frame.bg = bg
end