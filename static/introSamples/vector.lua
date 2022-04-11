local math = require "math"
local sqrt = math.sqrt
local atan2 = math.atan2

local vector = {}

local vector_mt

function vector.add(a, b)
  return vector(a[1] + b[1], a[2] + b[2])
end

function vector.sub(a, b)
  return vector(a[1] - b[1], a[2] - b[2])
end

function vector.scale(a, s)
  return vector(a[1]*s, a[2]*s)
end

function vector.mag2(v)
  return v[1]*v[1]+v[2]*v[2]
end

function vector.mag(v)
  return sqrt(v[1]*v[1]+v[2]*v[2])
end

function vector.unpack(v)
  return v[1], v[2]
end

function vector.eq(a, b)
  return type(a) == type(b) and a.x == b.x and a.y == b.y
end

function vector.theta(v)
  return atan2(v[2], v[1])
end

function vector.type(v)
  if getmetatable(v) == vector_mt then
    return "vector"
  else
    return type(v)
  end
end

local indices = {
  x = 1,
  y = 2
}

vector_mt = {
  __add = vector.add,
  __sub = vector.sub,
  __mul = function(a, b)
    if type(a) == "number" then
      return vector.scale(b, a)
    else
      return vector.scale(a, b)
    end
  end,
  __eq = vector.eq,
  __index = function(v, k)
    if indices[k] then
      return rawget(v, indices[k])
    else
      return vector[k]
    end
  end,
  __newindex = function(t, k, v)
    if indices[k] then
      rawset(t, indices[k], v)
    else
      rawset(t, k, v)
    end
  end,
  __tostring = function(v)
    return ("vector(%d, %d)"):format(v[1], v[2])
  end
}

setmetatable(vector, {
    __call = function(_, ...)
      return setmetatable({...}, vector_mt)
    end,
  }
)

return vector