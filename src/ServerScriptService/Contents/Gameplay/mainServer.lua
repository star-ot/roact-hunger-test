local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local FoodService = require(ReplicatedStorage.Common.FoodService)
local Network = require(ReplicatedStorage.Common.Network)
local module = {}

function module.init()
	local FoodService = FoodService.new()
	FoodService.init()
end

return module
