local _, Init = ...

-- Event handling: Initialize table to store registered events
local registeredEvents = {}

-- Create a frame to handle events
local eventHost = CreateFrame("Frame")

-- Set up event handler for the frame
eventHost:SetScript("OnEvent", function(_, event, ...)
	for callback in pairs(registeredEvents[event]) do
		callback(event, ...)
	end
end)

-- Function to register events with a callback function
function Init:RegisterEvent(event, callback)
	if not registeredEvents[event] then
		registeredEvents[event] = {}
		eventHost:RegisterEvent(event)
	end

	registeredEvents[event][callback] = true
end

function Init:UnregisterEvent(event, func)
	local funcs = registeredEvents[event]
	if funcs and funcs[func] then
		funcs[func] = nil

		if not next(funcs) then
			registeredEvents[event] = nil
			eventHost:UnregisterEvent(event)
		end
	end
end
