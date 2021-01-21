require "component"

Entity = {}

function Entity:new(world, tile)
	local fields = {world=world, tile=tile}
	self.__index = self
	return setmetatable(fields, self)
end

function Entity:addComponent(component)
	self.world.components[component.name][self] = component
	return self
end


entity_data = {
	{
		func=function (world,x,y) return Entity:new(world,cim):addComponent(PositionComponent:new(x,y)):addComponent(MoveableComponent:new()):addComponent(PathfindComponent:new()) end,
		name="Cim",
		tile=cim,
	},
	{
		func=function (world,x,y) return Entity:new(world,farm_empty):addComponent(PositionComponent:new(x,y)) end,
		name="Empty Farm",
		tile=farm_empty,
		feature=true
	},
	{
		func=function (world,x,y) return Entity:new(world,farm_wheat_seeds):addComponent(PositionComponent:new(x,y)) end,
		name="Seeded Wheat Farm",
		tile=farm_wheat_seeds,
		feature=true
	},
	{
		func=function (world,x,y) return Entity:new(world,farm_wheat_grown):addComponent(PositionComponent:new(x,y)) end,
		name="Grown Wheat Farm",
		tile=farm_wheat_grown,
		feature=true
	},
	{
		func=function (world,x,y) return Entity:new(world,wood_house):addComponent(PositionComponent:new(x,y)):addComponent(Component:new("collide")) end,
		name="Wooden House",
		tile=wood_house,
		feature=true
	},
	{
		func=function (world,x,y) return Entity:new(world,forest_tree):addComponent(PositionComponent:new(x,y)) end,
		name="Forest Tree",
		tile=forest_tree,
		feature=true
	},
	{
		func=function (world,x,y) return Entity:new(world,jungle_tree):addComponent(PositionComponent:new(x,y)):addComponent(Component:new("collide")) end,
		name="Jungle Tree",
		tile=jungle_tree,
		feature=true
	},
	{
		func=function (world,x,y) return Entity:new(world,dirt_road):addComponent(PositionComponent:new(x,y)) end,
		name="Dirt Road",
		tile=dirt_road,
		feature=true
	},
	{
		func=function (world,x,y) return Entity:new(world,stone_road):addComponent(PositionComponent:new(x,y)) end,
		name="Stone Road",
		tile=stone_road,
		feature=true
	}
}

entity_factories = {}
for _,ent in ipairs(entity_data) do
	entity_factories[ent.name] = ent.func
end
