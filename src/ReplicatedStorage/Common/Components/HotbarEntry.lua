local Roact = require(game.ReplicatedStorage.Modules.Roact)
local Players = game:GetService("Players")

-- De-selection does not work as intended at this time.

export type Props = {
	icon: string,
	quantity: number,
	foodType: string?,
	isSelected: boolean?,
	onSelect: (boolean) -> (),
}

local function HotbarEntry(props)
	local LocalPlayer = Players.LocalPlayer
	local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Char:WaitForChild("Humanoid")
	local isSelected = props.isSelected

    local frameColor = isSelected and Color3.fromRGB(148, 226, 213) or Color3.fromRGB(49, 50, 68) -- Blue for selected, black for others

    return Roact.createElement("ImageButton", {
        Size = UDim2.fromScale(0.125, 1),
        BackgroundTransparency = 0,
        BackgroundColor3 = frameColor,
        Image = props.icon,
        [Roact.Event.Activated] = function()
            if props.foodType then
                local toolName = props.foodType
                local hasTool = Char:FindFirstChild(toolName) or LocalPlayer.Backpack:FindFirstChild(toolName)
                local hasEquippedTool = Char:FindFirstChildOfClass("Tool")
                if hasTool and not hasEquippedTool then
                    Humanoid:EquipTool(hasTool)
                elseif hasTool and hasEquippedTool and hasEquippedTool.Name ~= toolName then
                    Humanoid:UnequipTools()
                    Humanoid:EquipTool(hasTool)
                elseif hasTool and hasEquippedTool and hasEquippedTool.Name == toolName then
                    Humanoid:UnequipTools()
                end
				if props.onSelect then
					props.onSelect()
				end
            end
        end,
    }, {
        UIAspectRatio = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1,
        }),
        Amount = Roact.createElement("TextLabel", {
            Text = tostring(props.quantity),
            Size = UDim2.fromScale(1, 0.5),
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextStrokeTransparency = 0,
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0.75, 0),
            BackgroundTransparency = 1,
        })
    })
end

return HotbarEntry
