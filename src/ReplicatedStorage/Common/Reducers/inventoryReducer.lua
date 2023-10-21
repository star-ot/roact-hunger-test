return function(state, action)
	-- This reducer is responsible for modifying the inventory for a specific player.
	-- @param state The current state of the inventoryState
	-- @param action The action to perform on the inventoryState
	-- @return The new state of the inventoryState

	state = state or {}
	
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
		if not state[playerId] then
			state[playerId] = {}
		end
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
end
