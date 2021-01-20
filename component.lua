require "system"

Component = {}

function Component:new(name)
	local fields = {name=name}
	self.__index = self
	return setmetatable(fields, self)
end

function Component:step()
	self.state = nextState
end

PositionComponent = Component:new()

function PositionComponent:new(x,y)
	local fields = Component.new(self, "position")
	fields.x = x
	fields.y = y
	return fields
end

MoveableComponent = Component:new()

function MoveableComponent:new()
	return Component.new(self, "moveable")
end

PathfindComponent = Component:new()

function PathfindComponent:new()
	return Component.new(self, "pathfind")
end

components = {
	"position",
	"moveable",
	"pathfind",
	"collide"
}