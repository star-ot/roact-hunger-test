local module = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Network = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Network"))
local connections = {}
local Store = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Reducers"):WaitForChild("Store"))
local LocalPlayer = Players.LocalPlayer

function module.init()
    Network.startClientAsync() -- Start the client network. This will connect to the server and start listening for events.

    Network.connectEvent(Network.RemoteEvents.FoodSpawned, function(foodType, position, foodId) -- Listen for the FoodSpawned event from the server to render the food.
        local foodPart = Instance.new("Part")
        foodPart.Size = Vector3.new(2,2,2)
        foodPart.Position = position
        if foodType.color then
            foodPart.Color = foodType.color
        end
        foodPart.Anchored = true
        foodPart.Name = foodType.name
        CollectionService:AddTag(foodPart, "Food")
        foodPart:SetAttribute("id", foodId)
        foodPart.Parent = Workspace:WaitForChild("Entities")
    end, Network.t.any, Network.t.Vector3, Network.t.number)

    Network.connectEvent(Network.RemoteEvents.PlayerDied, function() -- Listen for the PlayerDied event from the server to clean up the player's inventory and entities.
        print("Player died")
        Store:dispatch({
            type = "CLEAR_INVENTORY",
            playerId = LocalPlayer.UserId,
        })
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
        connections = {}
        for _, part in pairs(Workspace.Entities:GetChildren()) do
            part:Destroy()
        end
    end, Network.t.instanceOf("Player"))

    Network.connectEvent(Network.RemoteEvents.UpdateInventory, function(newInventoryState) -- Listen for the UpdateInventory event from the server to update the inventory state.
        --print(newInventoryState)
        Store:dispatch({
            type = "SET_INVENTORY",
            playerId = LocalPlayer.UserId,
            inventory = newInventoryState
        })
    end, Network.t.table)

    Network.connectEvent(Network.RemoteEvents.UpdateHunger, function(newHungerState) -- Listen for the UpdateHunger event from the server to update the hunger state.
        --print(newHungerState)
        Store:dispatch({
            type = "SET_HUNGER",
            playerId = LocalPlayer.UserId,
            hunger = newHungerState
        })
    end, Network.t.any) -- The hunger state is a number, but sometimes the whole hungerState is sent as a table, I meant to fix this but did not have time.
end

return module
