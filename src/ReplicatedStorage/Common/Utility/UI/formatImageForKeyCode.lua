--!strict

--[[
	Converts KeyCodes into image sprites for ease of creating button hints
	This assumes the sprite sheet is made up of squares of size ICON_SIZE_PIXELS
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerFacingString = require(ReplicatedStorage.Source.SharedConstants.PlayerFacingString)

local INPUT_SPRITES_ID = 9658715834
local ICON_SIZE_PIXELS = 48

local function getPropertiesAt(xIndex: number, yIndex: number)
	assert(xIndex >= 1 and yIndex >= 1, "Index must be a positive integer, starting with 1")

	return {
		ImageRectOffset = Vector2.new((xIndex - 1) * ICON_SIZE_PIXELS, (yIndex - 1) * ICON_SIZE_PIXELS),
		ImageRectSize = Vector2.one * ICON_SIZE_PIXELS,
	}
end

local propertiesByKeyCode = {
	[Enum.KeyCode.ButtonA] = getPropertiesAt(1, 1),
	[Enum.KeyCode.ButtonB] = getPropertiesAt(2, 1),
	[Enum.KeyCode.ButtonX] = getPropertiesAt(3, 1),
	[Enum.KeyCode.ButtonY] = getPropertiesAt(4, 1),
}

local function formatImageForKeyCode(imageObject: ImageLabel | ImageButton, keyCode: Enum.KeyCode)
	local properties = propertiesByKeyCode[keyCode]
	assert(properties, "Missing sprite for key " .. keyCode.Name)

	local imageObjectAny = imageObject :: any

	imageObjectAny.Image = PlayerFacingString.ImageAsset.Prefix .. INPUT_SPRITES_ID
	for property, value in pairs(properties) do
		imageObjectAny[property] = value
	end
end

return formatImageForKeyCode
