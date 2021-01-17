require "system"

Component = {}

function Component:new(system)
	local fields = {system=system, state={}, nextState={}}
	self.__index = self
	return setmetatable(fields, self)
end

function Component:step()
	self.state = nextState
end

WanderComponent = Component:new()

function WanderComponent:new()
	return Component.new(self,RandomWanderSystem:new())
end