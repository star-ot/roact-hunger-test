-- ReplicatedStorage.Common.FoodService.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Rodux = require(ReplicatedStorage.Modules.Rodux)
local RoactRodux = require(ReplicatedStorage.Modules.RoactRodux)
local Network = require(ReplicatedStorage.Common.Network)
local store = require(ReplicatedStorage.Common.Reducers.Store)
local foodTypes = require(ReplicatedStorage.Common.Enums)

-- Define types, I don't normally do it this way, but I'm giving it a try.
export type FoodType = {
    name: string,
    color: Color3,
    icon: string,
}

export type FoodData = {
    type: FoodType,
    position: Vector3,
}

export type FoodService = {
    new: () -> FoodService,
    init: () -> nil,
    StartReducingHunger: () -> (),
    StartSpawning: (Player, number) -> nil,
    SpawnFood: (Player) -> boolean,
    __index: FoodService,
}

-- Initialize FoodService
local FoodService: FoodService = {
    new = nil,
    init = nil,
    StartReducingHunger = nil,
    StartSpawning = nil,
    SpawnFood = nil,
    __index = nil,
}

FoodService.__index = FoodService

-- Track player foods
local playerFoods: {[number]: {[number]: FoodData}} = {}

function FoodService.new() -- constructor
    local self = {}
    setmetatable(self, FoodService)
    return self
end

-- Start reducing hunger for all players
function FoodService:StartReducingHunger()
    task.spawn(function()
        while true do
            task.wait(1)
            local currentState = store:getState()
            --print(currentState)
            for playerId, hunger in pairs(currentState.hungerState) do
                local player = Players:GetPlayerByUserId(playerId)
                local char = player.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    local hasDied = humanoid:GetAttribute("HasDied")
                    print(playerId, hunger)
                    if hunger > 0 and humanoid and humanoid.Health > 0 and not hasDied then
                        store:dispatch({
                            type = "SET_HUNGER",
                            playerId = playerId,
                            hunger = math.max(hunger - 5, 0)  -- reduce hunger but not below 0
                        })
                        local newHungerState = store:getState().hungerState[playerId]
                        Network.fireClient(Network.RemoteEvents.UpdateHunger, player, newHungerState)

                    elseif hunger <= 0 and humanoid and humanoid.Health > 0  then
                        humanoid:SetAttribute("HasDied", true)
                        playerFoods[playerId] = nil
                        humanoid.Health = 0
                    end
                end
            end
        end
    end)
end

-- Spawns a food for a player on the server but renders it on the client using the Network remote event.
function FoodService:SpawnFood(player)
    if not player then return false end
    local foodType = foodTypes[math.random(#foodTypes)]
    local position = Vector3.new(math.random(-50,50), 3, math.random(-50,50))
    
    if not playerFoods[player.UserId] then
        return false
    end
    local foodId = #playerFoods[player.UserId] + 1
    playerFoods[player.UserId][foodId] = {type = foodType, position = position}

    Network.fireClient(Network.RemoteEvents.FoodSpawned, player, foodType, position, foodId)
    return true
end

-- Start spawning food for a player, could be better.
function FoodService:StartSpawning(player, interval)
    task.spawn(function()
        if not player then return end
        if not playerFoods[player.UserId] then
            playerFoods[player.UserId] = {}
        end
        while player do
            task.wait()
            self:SpawnFood(player)
            task.wait(interval)
        end
    end)
end

local function characterAdded(char)
    local player = Players:GetPlayerFromCharacter(char)
    if not player then return end
    store:dispatch({
        type = "SET_HUNGER",
        playerId = player.UserId,
        hunger = 100
    })

    store:dispatch({
        type = "CLEAR_INVENTORY",
        playerId = player.UserId
    })
    local newState = store:getState()
    local newInventoryState = newState.inventoryState[player.UserId]
    local newHungerState = newState.hungerState[player.UserId]
    task.wait()
    Network.fireClient(Network.RemoteEvents.UpdateInventory, player, newInventoryState)
    Network.fireClient(Network.RemoteEvents.UpdateHunger, player, newHungerState)
    FoodService:StartSpawning(player, 2) -- TODO: fix this type issue

    char:WaitForChild("Humanoid").Died:Connect(function()
        store:dispatch({
            type = "SET_HUNGER",
            playerId = player.UserId,
            hunger = 100
        })

        -- clear their inventory
        store:dispatch({
            type = "CLEAR_INVENTORY",
            playerId = player.UserId
        })
        local newState = store:getState()
        local newInventoryState = newState.inventoryState[player.UserId]
        local newHungerState = newState.hungerState[player.UserId]
        task.wait()
        Network.fireClient(Network.RemoteEvents.UpdateInventory, player, newInventoryState)
        Network.fireClient(Network.RemoteEvents.UpdateHunger, player, newHungerState)
        Network.fireClient(Network.RemoteEvents.PlayerDied, player, player)
        -- reset all of the player's food
        playerFoods[player.UserId] = {}
        -- remove all of their tools
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Destroy()
            end
        end
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Destroy()
            end
        end
    end)
end

local function PlayerAdded(player)
    player.CharacterAdded:Connect(function(char)
        characterAdded(char)
    end)
    if player.Character then
        characterAdded(player.Character)
    end
end

function FoodService.init(events)

    local Players = game:GetService("Players")

    Players.PlayerAdded:Connect(PlayerAdded)

    Players.PlayerRemoving:Connect(function(player)
        store:dispatch({
            type = "SET_HUNGER",
            playerId = player.UserId,
            hunger = nil
        })

        playerFoods[player.UserId] = nil
    end)
    
    for _, player in pairs(Players:GetPlayers()) do
        PlayerAdded(player)
    end

    -- Bind the function for players to request food collection
    Network.bindFunction(Network.RemoteFunctions.RequestFoodCollect, function(player: Player, foodId: number)
        local foodData = playerFoods[player.UserId][foodId]
        if foodData then
            local char = player.Character
            if char then
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local distance = (rootPart.Position - foodData.position).Magnitude
                    if distance > 10 then
                        return false
                    end
                end
            end

            local tool = player.Backpack:FindFirstChild(foodData.type.name) or player.Character:FindFirstChild(foodData.type.name)
            if not tool then
                print("Creating tool", foodData.type.name)
                tool = Instance.new("Tool")
                tool.Name = foodData.type.name
                local handle = Instance.new("Part")
                handle.Name = "Handle"
                handle.Size = Vector3.new(1.5, 1.5, 1.5)
                handle.Color = foodData.type.color
                handle.Parent = tool
                CollectionService:AddTag(tool, "FoodTool")
                tool.Parent = player.Backpack
            end
            local state = store:getState()
            store:dispatch({
                type = "ADD_ITEM",
                playerId = player.UserId,
                item = foodData.type.name
            })


            local newInventoryState = state.inventoryState[player.UserId]
            Network.fireClient(Network.RemoteEvents.UpdateInventory, player, newInventoryState)

            playerFoods[player.UserId][foodId] = nil -- remove the food from the player's foods
            return true
        end
        return false
    end, Network.t.instanceOf("Player"), Network.t.number)
    
    -- Bind the function for players to request food consumption
    Network.connectEvent(Network.RemoteEvents.ConsumeFoodRequest, function(player: Player, foodType: string)
        print("$ Server: Consuming food ", foodType)
        local currentHunger = store:getState().hungerState[player.UserId] or 100
        local inventory = store:getState().inventoryState[player.UserId] or {}
        local foodCount
        for item, count in pairs(inventory) do
            if tostring(item) == tostring(foodType) then
                foodCount = count
            end
        end
        if foodCount == nil then
            return false
        end
        print(currentHunger, foodCount)
        if currentHunger > 0 and foodCount > 0 then
            store:dispatch({
                type = "SET_HUNGER",
                playerId = player.UserId,
                hunger = math.min(currentHunger + 10, 100)
            })

            store:dispatch({
                type = "CONSUME_FOOD",
                playerId = player.UserId,
                foodType = tostring(foodType)
            })

            local newInventoryState = store:getState().inventoryState[player.UserId]
            Network.fireClient(Network.RemoteEvents.UpdateInventory, player, newInventoryState)
            local newHungerState = store:getState().hungerState[player.UserId]
            Network.fireClient(Network.RemoteEvents.UpdateHunger, player, newHungerState)

            -- check if the foodCount is now 0, if it is, remove their tool
            for item, count in pairs(newInventoryState) do
                if tostring(item) == tostring(foodType) and count == 0 then
                    local char = player.Character
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    humanoid:UnequipTools()
                    local tool = player.Backpack:FindFirstChild(foodType) or char:FindFirstChild(foodType)
                    if tool then
                        if tool:IsA("Tool") then
                            tool:Destroy()
                        end
                    end
                end
            end

            return true
        end
        return false
    end, Network.t.instanceOf("Player"), Network.t.string)

    FoodService.StartReducingHunger()
end

return FoodService
