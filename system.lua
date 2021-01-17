System = {}

function System:new()
	local fields = {state={}, nextState={}}
	self.__index = self
	return setmetatable(fields, self)
end

function System:step(entity, component)

end


RandomWanderSystem = System:new()

function RandomWanderSystem:new()
	local fields = System.new(self)
	return fields
end

function RandomWanderSystem:step(entity, component, x, y)
	local dir = {x=love.math.random(-1,1),y=love.math.random(-1,1)}
	if entity.world:biomeAt(x+dir.x,y+dir.y) ~= biomes.water and not entity.world:entityAt(x+dir.x,y+dir.y) then
		entity.world:setEntityAt(x,y,nil)
		entity.world:setEntityAt(x+dir.x,y+dir.y,entity)
	end
end