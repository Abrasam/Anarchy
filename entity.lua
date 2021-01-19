require "component"

Entity = {}

function Entity:new(world, tile)
	local fields = {world=world, tile=tile}
	self.__index = self
	return setmetatable(fields, self)
end

function Entity:addComponent(component, initial)
	self.world.components[component][self] = Component:new(initial)
	return self
end


entity_factories = {
	{
		func=function (world,x,y) return Entity:new(world,cim):addComponent("position", {x=x,y=y}):addComponent("moveable"):addComponent("pathfind") end,
		name="Cim",
		tile=cim
	},
	{
		func=function (world,x,y) return Entity:new(world,farm_empty):addComponent("position", {x=x,y=y}) end,
		name="Empty Farm",
		tile=farm_empty
	},
	{
		func=function (world,x,y) return Entity:new(world,farm_wheat_seeds):addComponent("position", {x=x,y=y}) end,
		name="Seeded Wheat Farm",
		tile=farm_wheat_seeds
	},
	{
		func=function (world,x,y) return Entity:new(world,farm_wheat_grown):addComponent("position", {x=x,y=y}) end,
		name="Grown Wheat Farm",
		tile=farm_wheat_grown
	},
	{
		func=function (world,x,y) return Entity:new(world,wood_house):addComponent("position", {x=x,y=y}) end,
		name="Wooden House",
		tile=wood_house
	},
	{
		func=function (world,x,y) return Entity:new(world,forest_tree):addComponent("position", {x=x,y=y}) end,
		name="Forest Tree",
		tile=forest_tree
	},
	{
		func=function (world,x,y) return Entity:new(world,jungle_tree):addComponent("position", {x=x,y=y}) end,
		name="Jungle Tree",
		tile=jungle_tree
	},
}