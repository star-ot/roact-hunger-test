--!strict

--[[
	Searches children of an instance, returning the first child containing an attribute
	matching the given name and value.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Dependencies.Sift)
local Attribute = require(ReplicatedStorage.Source.SharedConstants.Attribute)

local function findFirstChildWithAttribute(
	parent: Instance,
	attributeName: Attribute.EnumType,
	attributeValue: any
): Instance?
	local children = parent:GetChildren()
	local index = Sift.Array.findWhere(children, function(instance: Instance)
		return instance:GetAttribute(attributeName) == attributeValue
	end)

	return if index then children[index] else nil
end

return findFirstChildWithAttribute
