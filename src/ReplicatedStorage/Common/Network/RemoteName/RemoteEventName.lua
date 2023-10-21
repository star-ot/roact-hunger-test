--!strict

--[[
	Specifies the names of all RemoteEvents. One RemoteEvent object gets generated for each name
	in this list, and these names are used as enums when interacting with Network to tell it
	which remote event to fire without typing out typo-prone string literals.
--]]

export type EnumType =
	"PlayerDataLoaded"
	| "PlayerDataUpdated"
	| "PlayerDataSaved"
	| "PlayerDied"
	| "FoodCollected"
	| "FoodSpawned"
	| "ConsumeFoodRequest"
	| "ResetData"
	| "UpdateInventory"
	| "UpdateHunger"

local RemoteEventName = {
	PlayerDataLoaded = "PlayerDataLoaded" :: "PlayerDataLoaded",
	PlayerDataUpdated = "PlayerDataUpdated" :: "PlayerDataUpdated",
	PlayerDataSaved = "PlayerDataSaved" :: "PlayerDataSaved",
	PlayerDied = "PlayerDied" :: "PlayerDied",
	FoodCollected = "FoodCollected" :: "FoodCollected",
	FoodSpawned = "FoodSpawned" :: "FoodSpawned",
	ConsumeFoodRequest = "ConsumeFoodRequest" :: "ConsumeFoodRequest",
	ResetData = "ResetData" :: "ResetData",
	UpdateInventory = "UpdateInventory" :: "UpdateInventory",
	UpdateHunger = "UpdateHunger" :: "UpdateHunger",
}

return RemoteEventName
