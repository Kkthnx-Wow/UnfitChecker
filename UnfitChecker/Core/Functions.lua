local _, Core = ...

-- Game version API
local _, _, _, interfaceVersion = GetBuildInfo()

function Core:IsRetail()
	return interfaceVersion > 100000
end

-- Checks if the current client is running the "classic era" version (e.g. vanilla).
function Core:IsClassicEra()
	return interfaceVersion < 20000
end

-- Checks if the current client is running the "classic" version.
function Core:IsClassic()
	return not Core:IsRetail() and not Core:IsClassicEra()
end
