local _, Core = ...

-- Load the Unfit library using LibStub
Core.LibUnfit = LibStub("Unfit-1.0")
-- Retrieve the player's level
Core.PlayerLevel = UnitLevel("player")
-- Define a path to a texture for use in UI elements
Core.White8x8TexturePath = "Interface\\BUTTONS\\WHITE8X8.BLP"
