System = {}

function System:new(components)
	local fields = {components=components}
	self.__index = self
	return setmetatable(fields, self)
end

function System:step(world)
	--implement in subclasses
end

MoveableSystem = System:new()

function MoveableSystem:new()
	return System.new(self, {"moveable"})
end

function MoveableSystem:step(world)
	for entity,component in pairs(world.components["moveable"]) do
		if component.state.next then
			if world:biomeAt(component.state.next.x, component.state.next.y) ~= biomes.water and not world:entityAt(component.state.next.x, component.state.next.y) then
				world:setEntityAt(component.state.current.x, component.state.current.y, nil)
				world:setEntityAt(component.state.next.x, component.state.next.y, entity)
				component.state.current = component.state.next
				component.state.next = nil
			end
		end
	end
end

local Grid = require "jumper.grid"
local Pathfinder = require "jumper.pathfinder"

PathfindSystem = System:new()

function PathfindSystem:new()
	return System.new(self, {"pathfind"})
end

function PathfindSystem:step(world)
	for entity,component in pairs(world.components["pathfind"]) do
		local mov = world.components["moveable"][entity]
		if component.state.target and not component.state.path then
			if mov.state.current.x == component.state.target.x and mov.state.current.y == component.state.target.y then
				component.state.target = nil
			end
			local grid = Grid(world:collisionMap())
			local pathfinder = Pathfinder(grid, 'JPS', 0)
			print("pathfind", component.state.target.x, component.state.target.y, mov.state.current.x, mov.state.current.y)
			local path = pathfinder:getPath(mov.state.current.x+1,mov.state.current.y+1,component.state.target.x+1,component.state.target.y+1)
			if path then
				print("path found!!!")
				component.state.path = {}
				for node,_ in path:nodes() do
					table.insert(component.state.path, {x=node.x-1,y=node.y-1})
					print(node.x-1, node.y-1, world:collisionMap()[node.x][node.y])
				end
			else
				component.state.target = nil --unreachable
			end
		end
		if component.state.path  then
			while #component.state.path > 0 and component.state.path[1].x == mov.state.current.x and component.state.path[1].y == mov.state.current.y do
				table.remove(component.state.path, 1)
			end
			if #component.state.path > 0 and not world.components["moveable"][entity].next then
				print("guacamole")
				
				local nxt = component.state.path[1]
				local diff = {
					x=nxt.x-mov.state.current.x > 0 and 1 or (nxt.x-mov.state.current.x < 0 and -1 or 0),
					y=nxt.y-mov.state.current.y > 0 and 1 or (nxt.y-mov.state.current.y < 0 and -1 or 0)
				}
				mov.state.next = {x=mov.state.current.x+diff.x,y=mov.state.current.y+diff.y}
				print("next", mov.state.current.x,mov.state.current.y,mov.state.next.x,mov.state.next.y,world:collisionMap()[mov.state.next.x+1][mov.state.next.y+1])
			else
				print("we done here doe")
				component.state.path = nil
			end
		end
	end
end

RandomWalkSystem = System:new()

function RandomWalkSystem:new()
	return System.new(self, {"pathfind"})
end

function RandomWalkSystem:step(world)
	for entity,component in pairs(world.components["pathfind"]) do
		local mov = world.components["moveable"][entity]
		while not component.state.target or world:biomeAt(component.state.target.x, component.state.target.y) == biomes.water or world:entityAt(component.state.target.x, component.state.target.y) do
			component.state.target = {x=mov.state.current.x+love.math.random(-20,20),y=mov.state.current.y+love.math.random(-20,20)}
		end
	end
end