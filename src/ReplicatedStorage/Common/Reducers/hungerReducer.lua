return function(state, action)
	-- This reducer is responsible for modifying the hunger for a specific player.
	-- @param state The current state of the hungerState
	-- @param action The action to perform on the hungerState
	-- @return The new state of the hungerState
	
	state = state or {}
	
	if action.type == "SET_HUNGER" then
		local playerId = action.playerId
		local hunger = action.hunger
		
		if playerId and hunger then
			state[playerId] = hunger  -- Modify the hunger for the specific player
		end
	end
	
	return state
end
