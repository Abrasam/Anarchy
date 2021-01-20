require "noise"
require "util"
require "textures"
require "entity"
require "world"
require "system"
require "component"

function love.load()
	tranX,tranY = math.floor(MAP_SIZE/2),math.floor(MAP_SIZE/2)
	world = World:new(love.math.random(100000))

	local td = love.filesystem.read("pathfind.lua")
	paththread = love.thread.newThread(td)
	pathfinder = love.thread.newChannel()
	paththread:start(pathfinder)

	add = 1
end

function love.resize(w, h)
end

function love.keypressed(key)
	if key == "right" then
		add = add + 1
		if add > #entity_data then
			add = 1
		end
	end
	if key == "left" then
		add = add - 1
		if add < 1 then
			add = #entity_data
		end
	end
end

function love.wheelmoved(x, y)
	TILE_SIZE = math.min(128, math.max(12,TILE_SIZE + 4*y))
end

function love.mousepressed(x,y,button)
	local tx,ty = mouseToTile(x,y)
	if button == 1 then
		if world:biomeAt(tx,ty) == biomes.water then return end
		local entity = entity_data[add].func(world,tx,ty)
		if entity_data[add].feature then
			world:setFeatureAt(tx,ty,entity)
		else
			world:setEntityAt(tx,ty,entity)
		end
	elseif button == 2 then
		world:setFeatureAt(tx,ty,nil)
	end
end

function love.update(dt)
	local move = love.keyboard.isDown("lshift") and 5 or 1
	if love.keyboard.isDown("w") then
		tranY = tranY - move
	end
	if love.keyboard.isDown("s") then
		tranY = tranY + move
	end
	if love.keyboard.isDown("a") then
		tranX = tranX - move
	end
	if love.keyboard.isDown("d") then
		tranX = tranX + move
	end
	tranX = math.min(math.max(tranX,0),MAP_SIZE-math.ceil(love.graphics.getWidth()/TILE_SIZE)-1)
	tranY = math.min(math.max(tranY,0),MAP_SIZE-math.ceil(love.graphics.getHeight()/TILE_SIZE)-1)
	world:update(dt)
end

function love.draw()
	world:draw(tranX,tranY)
	local tx,ty = math.floor(love.mouse.getX()/TILE_SIZE),math.floor(love.mouse.getY()/TILE_SIZE)
	love.graphics.rectangle("line",TILE_SIZE*tx,TILE_SIZE*ty,TILE_SIZE,TILE_SIZE)
	local mx,my = mouseToTile(love.mouse.getX(),love.mouse.getY())
	love.graphics.print(mx.." "..my)
	love.graphics.print(entity_data[add].name, love.graphics.getWidth()-256)
	love.graphics.draw(entity_data[add].tile, (love.graphics.getWidth()-128), 10, 0, 128/16, 128/16)
end

function mouseToTile(mx, my)
	return tranX+math.floor(mx/TILE_SIZE),tranY+math.floor(my/TILE_SIZE)
end