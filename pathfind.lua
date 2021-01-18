require "love.timer"

Grid = require "jumper.grid"
Pathfinder = require "jumper.pathfinder"


local inp = ...

local t = love.timer.getTime()
local timer = 0

while true do
	local t2 = love.timer.getTime()
	local dt = t2 - t
	t = t2
	timer = timer + dt
	if timer > 1 then
		timer = 0
		local tab = inp:demand()
		local tx,ty,map,x,y,ch = math.floor(tab.tx),math.floor(tab.ty),tab.map,tab.x,tab.y,tab.ch
		local grid = Grid(map)
		local pathfinder = Pathfinder(grid,'JPS',0)
		local path = nil
		local t,c = pcall(function () path = pathfinder:getPath(x+1,y+1,tx+1,ty+1) end)
		if path then path2 = {}
			for node, count in path:nodes() do
				table.insert(path2, {x=node.x-1, y=node.y-1})
			end
			ch:push(path2)
		else
			ch:push({})
		end
	end
end