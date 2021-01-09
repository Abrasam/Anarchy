function noise(x, y, z, octaves, lacunarity, persistence)
	local noise = 0;

	local amplitude = 1
	local frequency = 1
	local noiseHeight = 0
	local max = 0;

	for i=1,octaves do
		local sx = x * frequency + i*z
		local sy = y * frequency + i*z

		noise = noise + love.math.noise(sx,sy,z) * amplitude

		max = max + amplitude
		amplitude = amplitude * persistence
		frequency = frequency * lacunarity
	end

	return noise / max
end