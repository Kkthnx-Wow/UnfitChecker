local _, UnfitChecker = ...

-- WoW Globals
local G = {
	ITEM_MIN_LEVEL = ITEM_MIN_LEVEL, -- "Requires Level %d"
}

-- Check tooltip for the required level and other unfit conditions
function UnfitChecker:IsLootItemUsable(tooltip)
	local requiredLevelPattern = UnfitChecker.Pattern[G.ITEM_MIN_LEVEL]

	for i = 1, tooltip:NumLines() do
		local line = _G["GameTooltipTextLeft" .. i]:GetText()
		if line then
			local requiredLevel = line:match(requiredLevelPattern)
			if requiredLevel then
				return tonumber(requiredLevel)
			end
		end
	end

	return nil
end

function UnfitChecker:InitLootUsability()
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())
		if button and button.Item and button.GetElementData then
			-- Ensure usable texture exists for the button
			UnfitChecker:GetUnfitTexture(button.Item)

			local slotIndex = button:GetSlotIndex()
			local itemLink = GetLootSlotLink(slotIndex)
			if itemLink then
				-- Set the tooltip to parse the item
				GameTooltip:SetOwner(button, "ANCHOR_NONE")
				GameTooltip:SetHyperlink(itemLink)

				local itemMinLevel = UnfitChecker:IsLootItemUsable(GameTooltip) or 0 -- Fallback to 0 if IsItemUsable returns nil
				local itemLocked = select(6, GetLootSlotInfo(slotIndex))
				local isUnusable = UnfitChecker.LibUnfit:IsItemUnusable(itemLink) or ((itemMinLevel > 0 and itemMinLevel > UnfitChecker.PlayerLevel) and not itemLocked)

				-- Show or hide the unfit texture based on item usability and minimum level
				button.Item.UnfitTexture:SetShown(isUnusable)

				GameTooltip:Hide()
			elseif button.Item.UnfitTexture then
				-- Hide texture if itemLink is not present
				button.Item.UnfitTexture:SetShown(false)
			end
		end
	end
end

hooksecurefunc(LootFrame.ScrollBox, "Update", UnfitChecker.InitLootUsability)
