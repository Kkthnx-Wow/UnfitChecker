local _, UnfitChecker = ...

local GetItemInfo = C_Item and C_Item.GetItemInfo or GetItemInfo

-- Function: InitGuildBankUsability
-- Purpose: Sets up item usability indicators for guildbank.
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
function UnfitChecker:InitGuildBankUsability(addonName)
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
					UnfitChecker:GetUnfitTexture(button)

					local itemMinLevel = select(5, GetItemInfo(link))
					if UnfitChecker.LibUnfit:IsItemUnusable(link) or (itemMinLevel and itemMinLevel > UnfitChecker.PlayerLevel) then -- I do not think wow has API for locked items in guildbanks nor do I think locked items can even be in the guildbank?
						button.UnfitTexture:SetShown(true)
					else
						button.UnfitTexture:SetShown(false)
					end
				elseif button.UnfitTexture then
					button.UnfitTexture:SetShown(false)
				end
			end
		end
	end

	hooksecurefunc(_G.GuildBankFrame, "Update", UpdateGuildBankFrame)

	UnfitChecker:UnregisterEvent("ADDON_LOADED", UnfitChecker.InitGuildBankUsability)
end

-- Register IsItemUsable_GuildBank function to execute on ADDON_LOADED event
UnfitChecker:RegisterEvent("ADDON_LOADED", UnfitChecker.InitGuildBankUsability)
