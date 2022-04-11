local vector = require "vector"

local unitCircle = {}
for i=1, 8 do 
  unitCircle[i] = vector(math.cos(i*math.pi / 4), math.sin(i*math.pi / 4))
end

local circle2 = {}
for i, v in ipairs(unitCircle) do circle2[i] = v:scale(2) end

local accum = vector(0, 0)
for _, v in ipairs(circle2) do accum = accum + v end

print(accum:mag())