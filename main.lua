require "noise"
require "textures"
require "world"


function love.load()
	tranX,tranY = 0,0
	world = World:new(love.math.random(100000))
end

function love.resize(w, h)
end

function love.keypressed(key)
end

function love.wheelmoved(x, y)
	TILE_SIZE = math.min(128, math.max(8,TILE_SIZE + 4*y))
	
end

function love.mousepressed(x,y,button)
end

function love.update(dt)
	local move = love.keyboard.isDown("lshift") and 10 or 1
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
end

function love.draw()
	world:draw(tranX,tranY)
end
