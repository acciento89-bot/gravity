--!strict

local AccessibilityState = {}
local reducedMotion = false
local changed = Instance.new("BindableEvent")

AccessibilityState.Changed = changed.Event

function AccessibilityState.isReducedMotion(): boolean
	return reducedMotion
end

function AccessibilityState.setReducedMotion(value: boolean)
	local nextValue = value == true
	if nextValue == reducedMotion then
		return
	end
	reducedMotion = nextValue
	changed:Fire(reducedMotion)
end

function AccessibilityState.toggleReducedMotion(): boolean
	AccessibilityState.setReducedMotion(not reducedMotion)
	return reducedMotion
end

return AccessibilityState
