local _, UnfitChecker = ...

-- Local references for optimization
local select = select
local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local GetItemInfo = C_Item and C_Item.GetItemInfo or GetItemInfo

-- Function: InitializeBagUsabilityIndicators
-- Purpose: Sets up item usability indicators for bags and bank slots.
function UnfitChecker:InitBagUsability()
	-- Iterate through bag frames
	for i = 1, 13 do
		local containerFrame = _G["ContainerFrame" .. i]
		for _, button in containerFrame:EnumerateItems() do
			-- Associate button with its icon border and hook function
			button.IconBorder.__owner = button
			hooksecurefunc(button.IconBorder, "SetShown", UnfitChecker.UpdateBagUsability)
		end
	end
end

-- Function: UpdateBagUsability
-- Purpose: Updates the usability indicator for a specific bag or bank slot.
function UnfitChecker:UpdateBagUsability()
	local button = self.__owner

	-- Retrieve bag and slot IDs and item info
	local bagID = button:GetBagID()
	local slotID = button:GetID()
	local itemInfo = C_Container_GetContainerItemInfo(bagID, slotID)
	local isLocked = itemInfo and itemInfo.isLocked

	-- Check if item hyperlink exists
	if button and button:IsShown() then
		local hyperLink = itemInfo and itemInfo.hyperlink
		if hyperLink then
			-- Ensure usable texture exists for the button
			UnfitChecker:GetUnfitTexture(button)
			-- Fetch item minimum level once
			local itemMinLevel = select(5, GetItemInfo(hyperLink))
			-- Determine if item is unusable or above player level and not locked
			if (UnfitChecker.LibUnfit:IsItemUnusable(hyperLink) or (itemMinLevel and itemMinLevel > UnfitChecker.PlayerLevel)) and not isLocked then
				if not button.UnfitTexture:IsShown() then -- Show texture if not already shown
					button.UnfitTexture:SetShown(true)
				end
			else
				if button.UnfitTexture:IsShown() then -- Hide texture if not already hidden
					button.UnfitTexture:SetShown(false)
				end
			end
		elseif button.UnfitTexture then -- Hide texture if not already hidden
			button.UnfitTexture:SetShown(false)
		end
	end
end

-- Register InitBagUsability function to execute on PLAYER_LOGIN event
UnfitChecker:RegisterEvent("PLAYER_LOGIN", UnfitChecker.InitBagUsability)
