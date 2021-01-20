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
		if component.next then
			if world:biomeAt(component.next.x, component.next.y) ~= biomes.water and not world:entityAt(component.next.x, component.next.y) then
				world:setEntityAt(pos.x, pos.y, nil)
				world:setEntityAt(component.next.x, component.next.y, entity)
				pos.x = component.next.x
				pos.y = component.next.y
				component.next = nil
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
		if component.target and not component.path then
			if pos.x == component.target.x and pos.y == component.target.y then
				component.target = nil
			end
			--[[if component.waiting then
				while component.channel:getCount() > 0 do
					component.waiting = nil
					component.path = component.channel:pop()
					if #component.path == 0 then
						component.path = nil
						component.target = nil
					end
				end
			else
				component.channel = love.thread.newChannel()
				component.waiting = true
				pathfinder:push({tx=component.target.x,ty=component.target.y,map=world:collisionMap(),x=pos.x,y=pos.y,ch=component.channel})
				--print("new path", component.target.x, component.target.y)
			end]]
			local path = world.pathfinder:getPath(pos.x+1, pos.y+1, component.target.x+1, component.target.y+1)
			
			if not path or #path == 0 then
				component.path = nil
				component.target = nil
			else
				component.path = {}
				for node, _ in path:nodes() do
					table.insert(component.path, {x=node.x-1, y=node.y-1})
				end
			end
		end
		if component.path then
			while #component.path > 0 and component.path[1].x == pos.x and component.path[1].y == pos.y do
				table.remove(component.path, 1)
			end
			if #component.path > 0 and not mov.next then
				local nxt = component.path[1]
				local diff = {
					x=nxt.x-pos.x > 0 and 1 or (nxt.x-pos.x < 0 and -1 or 0),
					y=nxt.y-pos.y > 0 and 1 or (nxt.y-pos.y < 0 and -1 or 0)
				}
				mov.next = {x=pos.x+diff.x,y=pos.y+diff.y}
			else
				mov.next = nil
				component.path = nil
				if world:entityAt(component.target.x, component.target.y) then
					component.target = nil
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
		while not component.target or world:biomeAt(component.target.x, component.target.y) == biomes.water or world:entityAt(component.target.x, component.target.y) do
			component.target = {x=pos.x+love.math.random(-20,20),y=pos.y+love.math.random(-20,20)}
		end
	end
end