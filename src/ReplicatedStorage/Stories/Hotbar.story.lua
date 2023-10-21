local ReplicatedStorage = game:GetService("ReplicatedStorage") 
local Roact = require(ReplicatedStorage.Modules.Roact)
local Rodux = require(ReplicatedStorage.Modules.Rodux)
local RoactRodux = require(ReplicatedStorage.Modules.RoactRodux)
local Hotbar = require(ReplicatedStorage.Common.Components.Hotbar)

-- I wanted to make/update the stories but decided against it for time's sake and instead worked directly on the components.

local Store = Rodux.Store.new(function(state, action)
    state = state or {
        [game.Players.LocalPlayer.UserId] = {},
    }
    if action.type == "SET_INVENTORY" then
		local playerId = action.playerId
		local inventory = action.inventory
		
		if playerId and inventory then
			state[playerId] = inventory  -- Modify the inventory for the specific player
		end
	elseif action.type == "CLEAR_INVENTORY" then
		local playerId = action.playerId
		
		if playerId then
			state[playerId] = nil  -- Clear the inventory for the specific player
		end
	elseif action.type == "ADD_ITEM" then
		local playerId = action.playerId
		local item = action.item
		print("Adding item " .. item .. " to player " .. playerId)
		if playerId and item then
			local inventory = state[playerId]
			
			if inventory then
				if not inventory[item] then
					inventory[item] = 1
				else
					inventory[item] = inventory[item] + 1
				end
			elseif not inventory then
				inventory = {}
				inventory[item] = 1
			end

			state[playerId] = inventory
		end
	elseif action.type == "CONSUME_FOOD" then
		local playerId = action.playerId
		local foodType = action.foodType
		
		if playerId and foodType then
			local inventory = state[playerId]
			
			if inventory then
				if inventory[foodType] then
					print("Consuming food " .. foodType .. " for player " .. playerId)
					inventory[foodType] = inventory[foodType] - 1
				end
			end
			
			state[playerId] = inventory
		end
	end
	
	return state
end)

return function(target)
    local hotbar = Roact.createElement(RoactRodux.StoreProvider, {
        store = Store,
    }, {
        HotBar = Roact.createElement(Hotbar),
    })

    local handle = Roact.mount(hotbar, target, "Hotbar")

    task.delay(1, function()
        Store:dispatch({
            type = "ADD_ITEM",
            playerId = game.Players.LocalPlayer.UserId,
            item = "Apple",
        })
    end)

    return function()
        Roact.unmount(handle)
    end
end
