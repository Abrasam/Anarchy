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
	return System.new(self, {"position", "moveable"})
end

function MoveableSystem:step(world)
	for entity,component in pairs(world.components["moveable"]) do
		local pos = world.components["position"][entity]
		if component.state.next then
			if world:biomeAt(component.state.next.x, component.state.next.y) ~= biomes.water and not world:entityAt(component.state.next.x, component.state.next.y) then
				world:setEntityAt(pos.state.x, pos.state.y, nil)
				world:setEntityAt(component.state.next.x, component.state.next.y, entity)
				pos.state.x = component.state.next.x
				pos.state.y = component.state.next.y
				component.state.next = nil
			end
		end
	end
end

PathfindSystem = System:new()

function PathfindSystem:new()
	return System.new(self, {"pathfind", "moveable", "position"})
end

function PathfindSystem:step(world)
	for entity,component in pairs(world.components["pathfind"]) do
		local mov = world.components["moveable"][entity]
		local pos = world.components["position"][entity]
		if component.state.target and not component.state.path then
			if pos.state.x == component.state.target.x and pos.state.y == component.state.target.y then
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
				pathfinder:push({tx=component.state.target.x,ty=component.state.target.y,map=world:collisionMap(),x=pos.state.x,y=pos.state.y,ch=component.state.channel})
				--print("new path", component.state.target.x, component.state.target.y)
			end]]
			local path = world.pathfinder:getPath(pos.state.x+1, pos.state.y+1, component.state.target.x+1, component.state.target.y+1)
			
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
			while #component.state.path > 0 and component.state.path[1].x == pos.state.x and component.state.path[1].y == pos.state.y do
				table.remove(component.state.path, 1)
			end
			if #component.state.path > 0 and not mov.state.next then
				local nxt = component.state.path[1]
				local diff = {
					x=nxt.x-pos.state.x > 0 and 1 or (nxt.x-pos.state.x < 0 and -1 or 0),
					y=nxt.y-pos.state.y > 0 and 1 or (nxt.y-pos.state.y < 0 and -1 or 0)
				}
				mov.state.next = {x=pos.state.x+diff.x,y=pos.state.y+diff.y}
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
		local pos = world.components["position"][entity]
		while not component.state.target or world:biomeAt(component.state.target.x, component.state.target.y) == biomes.water or world:entityAt(component.state.target.x, component.state.target.y) do
			component.state.target = {x=pos.state.x+love.math.random(-20,20),y=pos.state.y+love.math.random(-20,20)}
		end
	end
end