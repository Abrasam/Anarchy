MAP_SIZE = 1000
HEIGHT_SCALE = 100
FOREST_SCALE = 10
MOISTURE_SCALE = 200
TEMP_SCALE = 50
FOOD_SCALE = 5
TILE_SIZE = 64

World = {}

function World:new(seed)
	local fields = {map=nil} --just there for documentation really
	self.__index = self
	fields =  setmetatable(fields, self)
	fields:generate(seed)
	return fields
end

function World:generate(seed)
	local h,t,m,f,fd=love.math.random(seed),love.math.random(seed),love.math.random(seed),love.math.random(seed),love.math.random(seed)
	local map = {}
	for x=0,MAP_SIZE-1 do
		map[x] = {}
		for y=0,MAP_SIZE-1 do
			local tile = {
				height=noise(x/HEIGHT_SCALE,y/HEIGHT_SCALE,h,5,2,0.5) * edge(x,y),
				forest=noise(x/FOREST_SCALE,y/FOREST_SCALE,t,3,2,0.6),
				moisture=noise(x/MOISTURE_SCALE,y/MOISTURE_SCALE,t,10,2,0.5),
				temp=noise(x/TEMP_SCALE,y/TEMP_SCALE,t,3,2,0.5),
				food=noise(x/FOOD_SCALE,y/FOOD_SCALE,fd,10,2,0.75)
			}
			map[x][y] = biome(tile)
		end
	end
	self.map = map
end

function World:draw(tranX, tranY)
	for x=0,math.ceil(love.graphics.getWidth()/TILE_SIZE) do
		for y=0,math.ceil(love.graphics.getHeight()/TILE_SIZE) do
			local xx,yy = tranX+x,tranY+y
			if xx >= 0 and xx < MAP_SIZE and yy >= 0 and yy < MAP_SIZE then
				if (not self.map[xx][yy]) then print(xx,yy) end
				love.graphics.draw(self.map[xx][yy].biome.tile, TILE_SIZE*(x-1), TILE_SIZE*(y-1), 0, TILE_SIZE/16, TILE_SIZE/16)
				if self.map[xx][yy].item then
					love.graphics.draw(self.map[xx][yy].item.tile, TILE_SIZE*(x-1), TILE_SIZE*(y-1), 0, TILE_SIZE/16, TILE_SIZE/16)
				end
			end
		end
	end
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
		return {biome=biomes.water,item=nil}
	else
		if tile.moisture < 0.4 then
			return {biome=biomes.desert,item=nil}
		else
			if tile.moisture > 0.6 then
				if tile.forest > 0.4 then
					return {biome=biomes.jungle,item=items.jungle_tree}
				else
					return {biome=biomes.water,item=nil}
				end
			else
				if tile.forest > 0.55 then
					return {biome=biomes.forest,item=items.forest_tree}
				else
					if tile.food > 0.6 then
						return {biome=biomes.plains, item=items.berry_bush}
					else
						return {biome=biomes.plains, item=nil}
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

Item = {}

function Item:new(name, tile)
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
}

items = {
	jungle_tree=Item:new("Jungle Tree", jungle_tree),
	forest_tree=Item:new("Forest Tree", forest_tree),
	berry_bush=Item:new("Berry Bush", berry_bush),
}