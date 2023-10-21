local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Modules.Roact)
local RoactRodux = require(ReplicatedStorage.Modules.RoactRodux)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local HungerBar = Roact.Component:extend("HungerBar")

export type Props = {
    hunger: number,
}

function HungerBar:init()
    self.state = {
        hunger = 100,
    }
end

function HungerBar:render()
    if not self.props.hunger then
        self.props.hunger = 100
    end

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.2, 0.1),
        Position = UDim2.fromScale(0.5, 0.1),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
    }, {
        HungerBar = Roact.createElement("Frame", {
            Size = UDim2.fromScale(self.props.hunger / 100, 1),
            BackgroundColor3 = Color3.fromRGB(243, 139, 168),
        }),
        HungerText = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "Hunger: " .. self.props.hunger,
            TextColor3 = Color3.fromRGB(205, 214, 244),
            TextScaled = true,
            ZIndex = 2,
        })
    })
end

return RoactRodux.connect(function(state)
    if state.hungerState[LocalPlayer.UserId] then
        return {
            hunger = state.hungerState[LocalPlayer.UserId],
        }
    else
        return {
            hunger = 100,
        }
    end
end)(HungerBar)