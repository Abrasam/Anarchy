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
