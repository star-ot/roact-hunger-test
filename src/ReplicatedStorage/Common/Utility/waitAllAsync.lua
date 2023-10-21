--!strict

--[[
	Takes a list of callbacks, and runs them as separate coroutines, yielding the current thread until all the coroutines are dead.

	This function yields until either all callbacks have returned, or a callback has errored. Returns success, result.

	Exposes similar functionality to Promise.All in JS, or WaitGroups in Go.
--]]

local function checkIfOtherThreadsAreDead(threads: { thread })
	for _, thread in ipairs(threads) do
		if thread ~= coroutine.running() then
			if coroutine.status(thread) ~= "dead" then
				return false
			end
		end
	end

	return true
end

type Callback = (...any) -> ...any

local function waitAllAsync(callbacks: { Callback }): (boolean, ...any)
	local baseThread = coroutine.running()
	local threads: { thread } = {}
	local hasErrored = false

	for _, callback in ipairs(callbacks) do
		local thisThread = coroutine.create(function()
			local success, result = pcall(callback)

			if success and not hasErrored then
				-- If this callback has completed, all other threads are dead, and we haven't already resumed on an error then we are good to proceed!
				if checkIfOtherThreadsAreDead(threads) then
					task.spawn(baseThread, true)
				end
			elseif not hasErrored then
				hasErrored = true

				task.spawn(baseThread, false, result)
			end
		end)

		table.insert(threads, thisThread)

		-- Use task.defer so this callback can't return before the baseThread has yielded
		task.defer(thisThread)
	end

	if #threads > 0 then
		-- We yield the main thread here so it can be resumed once the callbacks have completed
		return coroutine.yield(baseThread)
	else
		return true
	end
end

return waitAllAsync
