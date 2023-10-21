local FoodTool = {}
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Common.Network)
FoodTool.__index = FoodTool
FoodTool.TAG = "FoodTool"

local foodTools = {}

function FoodTool.new(tool)
    local self = {}
    setmetatable(self, FoodTool)
    self.tool = tool
    self.connections = {}
    self.connections["activated"] = tool.Activated:Connect(function()
        print("Consuming " .. tool.Name)
        Network.fireServer(Network.RemoteEvents.ConsumeFoodRequest, tool, tool.Name)
    end)
    print("Initialized food tool: " .. tool.Name)
    return self
end

function FoodTool:CleanUp()
    for _, connection in pairs(self.connections) do
        connection:Disconnect()
        connection = nil
    end
    print("Cleaned up food tool: " .. self.tool.Name)
end

local foodToolAddedSignal = CollectionService:GetInstanceAddedSignal(FoodTool.TAG)
local foodToolRemovedSignal = CollectionService:GetInstanceRemovedSignal(FoodTool.TAG)

function FoodTool.init()
    
    foodToolAddedSignal:Connect(function(tool)
        foodTools[tool] = FoodTool.new(tool)
    end)

    foodToolRemovedSignal:Connect(function(tool)
        foodTools[tool]:CleanUp()
        foodTools[tool] = nil
    end)

    for _, tool in ipairs(CollectionService:GetTagged(FoodTool.TAG)) do
        foodTools[tool] = FoodTool.new(tool)
    end

end

return FoodTool
