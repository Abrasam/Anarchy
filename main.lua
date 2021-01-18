require "noise"
require "textures"
require "entity"
require "world"
require "system"
require "component"


function love.load()
	tranX,tranY = 0,0
	world = World:new(love.math.random(100000))

	local td = love.filesystem.read("pathfind.lua")
	paththread = love.thread.newThread(td)
	pathfinder = love.thread.newChannel()
	paththread:start(pathfinder)
end

function love.resize(w, h)
end

function love.keypressed(key)
end

function love.wheelmoved(x, y)
	TILE_SIZE = math.min(128, math.max(16,TILE_SIZE + 4*y))
	
end

function love.mousepressed(x,y,button)
	local tx,ty = mouseToTile(x,y)
	world.emap[tx][ty] = Entity:new(world, cim):addComponent("moveable", {current={x=tx,y=ty}}):addComponent("pathfind")
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
end

function mouseToTile(mx, my)
	return tranX+math.floor(mx/TILE_SIZE),tranY+math.floor(my/TILE_SIZE)
end