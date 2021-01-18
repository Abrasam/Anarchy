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
		local path = world.components["pathfind"][entity]
		if component.state.next then
			if world:biomeAt(component.state.next.x, component.state.next.y) ~= biomes.water and not world:entityAt(component.state.next.x, component.state.next.y) then
				world:setEntityAt(component.state.current.x, component.state.current.y, nil)
				world:setEntityAt(component.state.next.x, component.state.next.y, entity)
				component.state.current = component.state.next
				component.state.next = nil
			else
				--print("failed pathfinding", component.state.next.x, component.state.next.y, path.state.target.x, path.state.target.y, path.state.path)
				--print(world:collisionMap()[component.state.next.y+1][component.state.next.x+1])
			end
		end
	end
end

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
			--[[if component.state.waiting then
				while component.state.channel:getCount() > 0 do
					component.state.waiting = nil
					component.state.path = component.state.channel:pop()
					if #component.state.path == 0 then
						component.state.path = nil
						component.state.target = nil
					end
				end
			else
				component.state.channel = love.thread.newChannel()
				component.state.waiting = true
				pathfinder:push({tx=component.state.target.x,ty=component.state.target.y,map=world:collisionMap(),x=mov.state.current.x,y=mov.state.current.y,ch=component.state.channel})
				--print("new path", component.state.target.x, component.state.target.y)
			end]]
			local path = world.pathfinder:getPath(mov.state.current.x+1, mov.state.current.y+1, component.state.target.x+1, component.state.target.y+1)
			
			if not path or #path == 0 then
				component.state.path = nil
				component.state.target = nil
			else
				component.state.path = {}
				for node, _ in path:nodes() do
					table.insert(component.state.path, {x=node.x-1, y=node.y-1})
				end
			end
		end
		if component.state.path then
			while #component.state.path > 0 and component.state.path[1].x == mov.state.current.x and component.state.path[1].y == mov.state.current.y do
				table.remove(component.state.path, 1)
			end
			if #component.state.path > 0 and not mov.state.next then
				local nxt = component.state.path[1]
				local diff = {
					x=nxt.x-mov.state.current.x > 0 and 1 or (nxt.x-mov.state.current.x < 0 and -1 or 0),
					y=nxt.y-mov.state.current.y > 0 and 1 or (nxt.y-mov.state.current.y < 0 and -1 or 0)
				}
				mov.state.next = {x=mov.state.current.x+diff.x,y=mov.state.current.y+diff.y}
			else
				mov.state.next = nil
				component.state.path = nil
				if world:entityAt(component.state.target.x, component.state.target.y) then
					component.state.target = nil
				end
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