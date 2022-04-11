local ffi = require "ffi"

ffi.cdef[[
typedef struct point {
  int x;
  int y;
} point ;
]]
local point
point = ffi.metatype("point", {
    __add = function (a, b) return point(a.x + b.x, a.y + b.y) end,
    __tostring = function (val) return ("point(%d, %d)"):format(val.x, val.y) end
  }
)

a = point (1, 1)
b = point(2, 2)
c = a + b
print(c)