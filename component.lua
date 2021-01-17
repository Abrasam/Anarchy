require "system"

Component = {}

function Component:new(initial)
	local fields = {state=initial or {}}
	self.__index = self
	return setmetatable(fields, self)
end

function Component:step()
	self.state = nextState
end

components = {
	"moveable",
	"pathfind"
}