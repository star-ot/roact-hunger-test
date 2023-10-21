local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Roact = require(ReplicatedStorage.Modules.Roact)
local RoactRodux = require(ReplicatedStorage.Modules.RoactRodux)
local HotbarEntry = require(ReplicatedStorage.Common.Components.HotbarEntry)
local foodTypes = require(ReplicatedStorage.Common.Enums)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Hotbar = Roact.Component:extend("Hotbar")

export type Props = {
	inventory: {[string]: number},
}

export type State = {
	selectedEntry: string?,
}
function Hotbar:handleAction(actionName, inputState, inputObject)
	local Character = LocalPlayer.Character
	if not Character then return end
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end
	if inputState == Enum.UserInputState.Begin then
		-- map each HotbarEntry to a number
		self.hotbarEntries = {}
		for index, foodType in ipairs(foodTypes) do
			if self.props.inventory and self.props.inventory[foodType.name] and self.props.inventory[foodType.name] > 0 then
				table.insert(self.hotbarEntries, foodType)
			end
		end
		local indexValue = inputObject.KeyCode.Value - 48 -- convert from KeyCode to number to find the index

		-- This is pretty gnarly, I would have loved to clean up some of this some more as well as fixing de-selection.
		if self.hotbarEntries[indexValue] then
			local foodId = self.hotbarEntries[indexValue].name
			local isSelected = self.state.selectedEntry == foodId
			local tool = LocalPlayer.Backpack:FindFirstChild(foodId)
			local equippedTool = Character:FindFirstChild(foodId)
			if tool and not equippedTool then
				Humanoid:EquipTool(tool)
				self:selectEntry(foodId)
			elseif tool and equippedTool and equippedTool.Name ~= foodId then
				Humanoid:UnequipTools()
				Humanoid:EquipTool(tool)
				self:selectEntry(foodId)
			else
				Humanoid:UnequipTools()
				self:deselectEntry()
			end
		end
	end
end

function Hotbar:init()
    self.state = {
        selectedEntry = nil,
    }
end

function Hotbar:didMount()
	ContextActionService:BindAction("Hotbar", function(...)
		self:handleAction(...)
	end, false, Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine)
end

function Hotbar:selectEntry(foodType)
    self:setState({
        selectedEntry = foodType,
    })
end

function Hotbar:deselectEntry()
    self:setState({
        selectedEntry = nil,
    })
end

function Hotbar:render()
	self.hotbarEntries = {}
    for index, foodType in ipairs(foodTypes) do
        if self.props.inventory and self.props.inventory[foodType.name] and self.props.inventory[foodType.name] > 0 then
            local isSelected = self.state.selectedEntry == foodType.name
            table.insert(self.hotbarEntries, Roact.createElement(HotbarEntry, {
                foodType = foodType.name,
                icon = foodType.icon,
                quantity = self.props.inventory[foodType.name],
                layoutOrder = index,
                isSelected = isSelected,
                onSelect = function(isSelected)
                    if isSelected then
                        self:deselectEntry() -- Deselect if already selected
                    else
                        self:selectEntry(foodType.name) -- Select if not selected
                    end
                end,
            }))
        end
    end

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.6, 0.125),
        Position = UDim2.fromScale(0.5, 1),
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
    }, {
        UILayout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0.05, 0),
        }),
        -- create a fragment of HotbarEntry components
		Entries = Roact.createFragment(self.hotbarEntries),
    })
end

return RoactRodux.connect(function(state)
    if state and state.inventoryState and state.inventoryState[LocalPlayer.UserId] then
        return {
            inventory = state.inventoryState[LocalPlayer.UserId],
        }
    else
        return {
            inventory = {},
        }
    end
end)(Hotbar)
