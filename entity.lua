require "component"

Entity = {}

function Entity:new(world, tile)
	local fields = {components={}, world=world, tile=tile}
	self.__index = self
	return setmetatable(fields, self)
end

function Entity:addComponent(component)
	table.insert(self.components, component)
	return self
end

function Entity:step(x,y)
	for _,component in ipairs(self.components) do
		component:step()
		component.system:step(self, component, x, y)
	end
end