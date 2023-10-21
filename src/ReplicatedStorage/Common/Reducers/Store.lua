-- This is the store that combines all of the reducers into one.
-- It also contains the initial state of the store.
-- @return always returns the store

local Rodux = require(game.ReplicatedStorage.Modules.Rodux)
local inventoryReducer = require(game.ReplicatedStorage.Common.Reducers.inventoryReducer)
local hungerReducer = require(game.ReplicatedStorage.Common.Reducers.hungerReducer)

-- Combine all reducers into one
local rootReducer = Rodux.combineReducers({
	inventoryState = inventoryReducer,
	hungerState = hungerReducer,
})

-- Set the initial state of the store, should have been done differently.
local initialState = {
	inventoryState = {},  -- Empty, will be filled dynamically with {playerId = inventory, ...}
	hungerState = {},  -- Empty, will be filled dynamically with {playerId = hunger, ...}
}

local loggerMiddleware = Rodux.loggerMiddleware

local store = Rodux.Store.new(rootReducer, initialState, {loggerMiddleware})

return store
