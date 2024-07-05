local _, Core = ...

-- Helper function to create or initialize button.usableTexture
function Core:GetUnfitTexture(button)
	if not button.UnfitTexture then
		button.UnfitTexture = button:CreateTexture(nil, "ARTWORK")
		button.UnfitTexture:SetTexture(Core.White8x8TexturePath)
		button.UnfitTexture:SetAllPoints(button)
		button.UnfitTexture:SetVertexColor(1, 0, 0)
		button.UnfitTexture:SetBlendMode("MOD")
		button.UnfitTexture:SetShown(false) -- Initialize as hidden
	end
end

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
