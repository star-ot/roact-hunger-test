local module = {}
module.priority = 10
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Roact = require(ReplicatedStorage.Modules.Roact)
local RoactRodux = require(ReplicatedStorage.Modules.RoactRodux)
local Network = require(ReplicatedStorage.Common.Network)
local Store = require(ReplicatedStorage.Common.Reducers.Store)
local Hotbar = require(ReplicatedStorage.Common.Components.Hotbar)
local HungerBar = require(ReplicatedStorage.Common.Components.HungerBar)

local connections = {}

local app = Roact.createElement(RoactRodux.StoreProvider, {
    store = Store,
}, {
    UI = Roact.createFragment({
        Hotbar = Roact.createElement(Hotbar),
        HungerBar = Roact.createElement(HungerBar),
    })
})

local function cleanup()
	for _, connection in pairs(connections) do
		connection:Disconnect()
		connection = nil
	end
end

function module.init()
	cleanup()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

    Roact.mount(app, LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui"), "UI")

	local humanoid = Char:WaitForChild("Humanoid")
	connections["died"] = humanoid.Died:Connect(function()
		Store:dispatch({
			type = "CLEAR_INVENTORY",
			playerId = LocalPlayer.UserId,
		})
		cleanup()
		for _, part in pairs(Workspace.Entities:GetChildren()) do
			part:Destroy()
		end
	end)
end

return module
