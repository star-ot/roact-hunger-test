--!strict
-- Specifies the names and properties of all food types
-- @field name The name of the food type
-- @field color The color of the food type
-- @field icon The icon of the food type


export type FoodType = {
    name: string,
    color: Color3,
    icon: string,
}

local module: {[number]: FoodType} = {
    {
        name = "Apple", 
        color = Color3.fromRGB(243, 139, 168),
        icon = "rbxassetid://115782078",
    },
    {
        name = "Banana", 
        color = Color3.fromRGB(249, 226, 175),
        icon = "rbxassetid://13500887025",
    },
    {
        name = "Orange", 
        color = Color3.fromRGB(255, 165, 0),
        icon = "rbxassetid://6869120302",
    },
    {
        name = "Grapes", 
        color = Color3.fromRGB(203, 166, 247),
        icon = "rbxassetid://1553608067",
    },
    {
        name = "Blueberries", 
        color = Color3.fromRGB(137, 180, 250),
        icon = "rbxassetid://13010655667",
    },
    {
        name = "Kiwi", 
        color = Color3.fromRGB(166, 227, 161),
        icon = "rbxassetid://193115299",
    },
    -- other food types
}

return module
