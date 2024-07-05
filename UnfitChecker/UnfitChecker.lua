local _, UnfitChecker = ...

-- Local references for optimization
local select = select
local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local GetItemInfo = C_Item.GetItemInfo or GetItemInfo

-- Helper function to create or initialize button.usableTexture
local function InitializeUsableTexture(button)
	if not button.usableTexture then
		button.usableTexture = button:CreateTexture(nil, "ARTWORK")
		button.usableTexture:SetTexture(UnfitChecker.White8x8TexturePath)
		button.usableTexture:SetAllPoints(button)
		button.usableTexture:SetVertexColor(1, 0, 0)
		button.usableTexture:SetBlendMode("MOD")
		button.usableTexture:Hide() -- Initialize as hidden
	end
end

-- Function: IsItemUsable_Containers
-- Purpose: Sets up item usability indicators for bags and bank slots.
function UnfitChecker:IsItemUsable_Containers()
	-- Iterate through bag frames
	for i = 1, 13 do
		local containerFrame = _G["ContainerFrame" .. i]
		for _, button in containerFrame:EnumerateItems() do
			-- Associate button with its icon border and hook function
			button.IconBorder.__owner = button
			hooksecurefunc(button.IconBorder, "SetShown", UnfitChecker.IsItemUsable_UpdateBags)
		end
	end

	-- Iterate through bank slots
	for i = 1, 28 do
		local button = _G["BankFrameItem" .. i]
		button.IconBorder.__owner = button
		hooksecurefunc(button.IconBorder, "SetShown", UnfitChecker.IsItemUsable_UpdateBags)
	end
end

-- Function: IsItemUsable_GuildBank
-- Purpose: Sets up item usability indicators for guildbank.
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
function UnfitChecker:IsItemUsable_GuildBank(addonName)
	if not UnfitChecker:IsRetail() then -- Classic does not have guildbanks!
		return
	end

	if addonName ~= "Blizzard_GuildBankUI" then
		return
	end

	local function UpdateGuildBankFrame()
		local guildBankFrame = _G.GuildBankFrame
		if not guildBankFrame or guildBankFrame.mode ~= "bank" then
			return
		end

		local tab = GetCurrentGuildBankTab()
		if not tab then
			return
		end

		local columns = guildBankFrame.Columns
		if not columns then
			return
		end

		for i = 1, #columns * NUM_SLOTS_PER_GUILDBANK_GROUP do
			local index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
			if index == 0 then
				index = NUM_SLOTS_PER_GUILDBANK_GROUP
			end
			local column = ceil((i - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
			local button = columns[column] and columns[column].Buttons and columns[column].Buttons[index]

			if button and button:IsShown() then
				local link = GetGuildBankItemLink(tab, i)
				if link then
					InitializeUsableTexture(button)

					local itemMinLevel = select(5, GetItemInfo(link))
					if UnfitChecker.LibUnfit:IsItemUnusable(link) or (itemMinLevel and itemMinLevel > UnfitChecker.PlayerLevel) then -- I do not think wow has API for locked items in guildbanks nor do I think locked items can even be in the guildbank?
						button.usableTexture:SetShown(true)
					else
						button.usableTexture:SetShown(false)
					end
				elseif button.usableTexture then
					button.usableTexture:Hide()
				end
			end
		end
	end

	hooksecurefunc(_G.GuildBankFrame, "Update", UpdateGuildBankFrame)

	UnfitChecker:UnregisterEvent("ADDON_LOADED", UnfitChecker.IsItemUsable_GuildBank)
end

-- Function: IsItemUsable_UpdateBags
-- Purpose: Updates the usability indicator for a specific bag or bank slot.
function UnfitChecker:IsItemUsable_UpdateBags()
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
			InitializeUsableTexture(button)
			-- Fetch item minimum level once
			local itemMinLevel = select(5, GetItemInfo(hyperLink))
			-- Determine if item is unusable or above player level and not locked
			if (UnfitChecker.LibUnfit:IsItemUnusable(hyperLink) or (itemMinLevel and itemMinLevel > UnfitChecker.PlayerLevel)) and not isLocked then
				if not button.usableTexture:IsShown() then -- Show texture if not already shown
					button.usableTexture:SetShown(true)
				end
			else
				if button.usableTexture:IsShown() then -- Hide texture if not already hidden
					button.usableTexture:SetShown(false)
				end
			end
		elseif button.usableTexture then -- Hide texture if not already hidden
			button.usableTexture:SetShown(false)
		end
	end
end

-- Register IsItemUsable_Containers function to execute on PLAYER_LOGIN event
UnfitChecker:RegisterEvent("PLAYER_LOGIN", UnfitChecker.IsItemUsable_Containers)
-- Register IsItemUsable_GuildBank function to execute on ADDON_LOADED event
UnfitChecker:RegisterEvent("ADDON_LOADED", UnfitChecker.IsItemUsable_GuildBank)
