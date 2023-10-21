-- Primarily for Client usage.
-- This is a class that represents a food item in the game.
local Food = {}
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Common.Network)
local foodTypes = require(ReplicatedStorage.Common.Enums)

Food.__index = Food
Food.TAG = "Food"

local foods = {}

function Food.new(food, position)
    local self = {}
    setmetatable(self, Food)
    self.food = food
    self.connections = {}
    self.proximityPrompt = Instance.new("ProximityPrompt")
    self.proximityPrompt.ActionText = "Pick up"
    self.proximityPrompt.ObjectText = food.Name
    self.proximityPrompt.MaxActivationDistance = 8
    self.proximityPrompt.Parent = food

    self.connections["proxTriggered"] = self.proximityPrompt.Triggered:Connect(function()
        print("Food collected with id: " .. food:GetAttribute("id"))
        local success = Network.invokeServerAsync(Network.RemoteFunctions.RequestFoodCollect, food:GetAttribute("id"))
        if success then
            food:Destroy()
        end
    end)
    print("Initialized food: " .. food.Name)
    return self
end

local foodAddedSignal = CollectionService:GetInstanceAddedSignal(Food.TAG)
local foodRemovedSignal = CollectionService:GetInstanceRemovedSignal(Food.TAG)

function Food.init()

    foodAddedSignal:Connect(function(food)
        local foodType
        for i, foodData in ipairs(foodTypes) do
            if foodData.name == food.Name then
                foodType = foodData
                break
            end
        end
        if foodType then
            foods[food] = Food.new(food, food.Position)
        end
    end)

    foodRemovedSignal:Connect(function(food)
        foods[food] = nil
    end)

    for _, food in ipairs(CollectionService:GetTagged(Food.TAG)) do
        local foodType
        for i, foodData in ipairs(foodTypes) do
            if foodData.name == food.Name then
                foodType = foodData
                break
            end
        end
        if foodType then
            foods[food] = Food.new(food, food.Position)
        end
    end
end

return Food
