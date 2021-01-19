require "entity"
require "component"

Grid = require "jumper.grid"
Pathfinder = require "jumper.pathfinder"

MAP_SIZE = 1000
HEIGHT_SCALE = 100
FOREST_SCALE = 10
MOISTURE_SCALE = 200
TEMP_SCALE = 50
FOOD_SCALE = 5
TILE_SIZE = 64
STEP_SIZE = 0.25

World = {}

function World:new(seed)
	local fields = {bmap={}, emap={}, cmap={}, systems={MoveableSystem:new(),PathfindSystem:new(),RandomWalkSystem:new()}, components={}, t=0}
	for _,component in ipairs(components) do
		fields.components[component] = {}
	end
	self.__index = self
	fields =  setmetatable(fields, self)
	fields:generate(seed)
	fields.grid = Grid(fields.cmap)
	fields.pathfinder = Pathfinder(fields.grid, 'JPS', 0)
	return fields
end

function World:generate(seed)
	local h,t,m,f,fd=love.math.random(seed),love.math.random(seed),love.math.random(seed),love.math.random(seed),love.math.random(seed)
	local bmap = {}
	local emap = {}
	for x=0,MAP_SIZE-1 do
		bmap[x] = {}
		emap[x] = {}
		for y=0,MAP_SIZE-1 do
			local tile = {
				height=noise(x/HEIGHT_SCALE,y/HEIGHT_SCALE,h,5,2,0.5) * edge(x,y),
				forest=noise(x/FOREST_SCALE,y/FOREST_SCALE,t,3,2,0.6),
				moisture=noise(x/MOISTURE_SCALE,y/MOISTURE_SCALE,t,10,2,0.5),
				temp=noise(x/TEMP_SCALE,y/TEMP_SCALE,t,3,2,0.5),
				food=noise(x/FOOD_SCALE,y/FOOD_SCALE,fd,10,2,0.75)
			}
			local data = biome(tile)
			bmap[x][y] = data.biome
			emap[x][y] = data.entity
		end
	end
	self.bmap = bmap
	self.emap = emap
	local cmap = {}
	for y=0,MAP_SIZE-1 do
		cmap[y+1] = {}
		for x=0,MAP_SIZE-1 do
			cmap[y+1][x+1] = 0
			if self.bmap[x][y] == biomes.water then
				cmap[y+1][x+1] = 1
			end
			if self.emap[x][y] then
				cmap[y+1][x+1] = 1
			end
		end
	end
	self.cmap = cmap
end

function World:draw(tranX, tranY)
	for x=0,math.ceil(love.graphics.getWidth()/TILE_SIZE) do
		for y=0,math.ceil(love.graphics.getHeight()/TILE_SIZE) do
			local xx,yy = tranX+x,tranY+y
			if xx >= 0 and xx < MAP_SIZE and yy >= 0 and yy < MAP_SIZE then
				love.graphics.draw(self.bmap[xx][yy].tile, TILE_SIZE*x, TILE_SIZE*y, 0, TILE_SIZE/16, TILE_SIZE/16)
				if self.emap[xx][yy] then
					love.graphics.draw(self.emap[xx][yy].tile, TILE_SIZE*x, TILE_SIZE*y, 0, TILE_SIZE/16, TILE_SIZE/16)
				end
			end
		end
	end
end

function World:update(dt)
	self.t = self.t + dt
	while self.t > STEP_SIZE do
		self.t = self.t - STEP_SIZE
		for _,system in ipairs(self.systems) do
			system:step(self)
		end
	end
end

function World:biomeAt(x,y)
	if x < 0 or x >= MAP_SIZE or y < 0 or y >= MAP_SIZE then
		return biomes.water
	else
		return self.bmap[x][y]
	end
end

function World:entityAt(x,y)
	if x < 0 or x >= MAP_SIZE or y < 0 or y >= MAP_SIZE then
		return nil
	else
		return self.emap[x][y]
	end
end

function World:setBiomeAt(x,y,biome)
	if x < 0 or x >= MAP_SIZE or y < 0 or y >= MAP_SIZE then
		return false
	else
		self.bmap[x][y] = biome
		self:updateCollisions(x,y)
		return true
	end
end

function World:setEntityAt(x,y,entity)
	if x < 0 or x >= MAP_SIZE or y < 0 or y >= MAP_SIZE then
		return false
	else
		self.emap[x][y] = entity
		self:updateCollisions(x,y)
		return true
	end
end

function World:updateCollisions(x,y)
	self.cmap[y+1][x+1] = 0
	if self.bmap[x][y] == biomes.water then
		self.cmap[y+1][x+1] = 1
	end
	if self.emap[x][y] then
		self.cmap[y+1][x+1] = 1
	end
end

function World:collisionMap()
	return self.cmap
end

function edge(x,y)
	local out = 1
	if x < 0.1*MAP_SIZE then
		out = out * x/(0.1*MAP_SIZE)
	end
	if x > 0.9*MAP_SIZE then
		out = out * (MAP_SIZE-x)/(0.1*MAP_SIZE)
	end
	if y < 0.1*MAP_SIZE then
		out = out * y/(0.1*MAP_SIZE)
	end
	if y > 0.9*MAP_SIZE then
		out = out * (MAP_SIZE-y)/(0.1*MAP_SIZE)
	end
	return out
end

function biome(tile)
	if tile.height < 0.4 then
		return {biome=biomes.water,entity=nil}
	else
		if tile.moisture < 0.4 then
			if tile.moisture > 0.35 and tile.forest > 0.4 then
				return {biome=biomes.desert,entity=nil}
			else
				return {biome=biomes.desert,entity=nil}
			end
		else
			if tile.moisture > 0.6 then
				if tile.forest > 0.42 then
					return {biome=biomes.jungle,entity=entitys.jungle_tree()}
				else
					if tile.moisture > 0.65 then
						return {biome=biomes.water,entity=nil}
					else
						return {biome=biomes.jungle,entity=nil}
					end
				end
			else
				if tile.forest > 0.55 then
					return {biome=biomes.forest,entity=entitys.forest_tree()}
				else
					if tile.food > 0.6 then
						return {biome=biomes.plains, entity=entitys.berry_bush()}
					else
						return {biome=biomes.plains, entity=nil}
					end
				end
			end
		end
	end
end

Biome = {}

function Biome:new(name, tile)
	local fields = {tile=tile}
	self.__index = self
	return setmetatable(fields, self)
end

biomes = {
	water=Biome:new("Ocean", water),
	forest=Biome:new("Forest", grass),
	plains=Biome:new("Plains", grass),
	desert=Biome:new("Desert", sand),
	jungle=Biome:new("Jungle", underbrush),
	farm=Biome:new("farm", farmland)
}

entitys = {
	jungle_tree=function() return Entity:new(world, jungle_tree) end,
	forest_tree=function() return Entity:new(world, forest_tree) end,
	berry_bush=function() return Entity:new(world, berry_bush) end,
}
