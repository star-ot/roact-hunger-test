--!strict

--[[
	Compares two dictionaries, including dictionaries containing nested tables.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Dependencies.Sift)

local function compare(value1: any, value2: any)
	if value1 == nil or value2 == nil then
		return false
	end

	local value1Type = typeof(value1)
	local value2Type = typeof(value2)

	if value1Type ~= value2Type then
		return false
	end

	if value1Type == "table" then
		return Sift.Dictionary.equalsDeep(value1, value2)
	end

	return value1 == value2
end

return function(object1: { [any]: any }, object2: { [any]: any })
	local keysChanged: { string } = {}

	-- Finding keys in object1 that are absent or changed in object2
	for key, value in pairs(object1) do
		local otherValue = object2[value]

		if not compare(value, otherValue) then
			table.insert(keysChanged, key)
		end
	end

	-- Find keys that are present in object2 but not present in object1
	for key, value in pairs(object2) do
		local otherValue = object1[value]

		if not otherValue then
			table.insert(keysChanged, key)
		end
	end

	return keysChanged
end
