

-- This file involves fixed point math and requires being picky about significant bits and precision.
-- It will be very difficult if you do not know fixed point math well.

--[[
    To load this file, run tests, and inspect code, you can use
    ```
    pc = assert(terralib.loadfile "precompute.t")()
    print(pc.evaluate_sin())
    pc.sinfixed:disas()
    ```
    The LUT uses two bytes of data per entry and the assembly listing of the sinfixed includes instruction offsets
    The instruction offset to the end of the function allows reading the size of the function.
]]

local M = {}

-- A signed fixed point number with eight bits of integer precision and eight bits of fractional precision
local struct S88fixed { val: int16 }

M.S88fixed = S88fixed

local meta = S88fixed.metamethods

meta.__cast = function(from, to, exp)
	if from:isfloat() and to == S88fixed then
		return `[S88fixed] { [int16](exp * 256) }
	elseif from:isintegral() and to == S88fixed then
		return `[S88fixed] { [int16](exp) * 256 }
	elseif from == S88fixed and to:isfloat() then
		return `[to](exp.val)/256
	elseif from == S88fixed and to:isintegral() then
		return `[to](exp.val/256)
	end
	error "invalid cast"
end

-- NOTE: This doesn't perform arithmetic type promotion properly.
-- Instead, it just assumes that both operands are S88fixed.
-- for extra credit, implement type promotion.
meta.__add = macro(function (a, b) return `[S88fixed] {a.val + b.val} end)
meta.__sub = macro(function (a, b) return `[S88fixed] {a.val - b.val} end)
meta.__mul = macro(function (a, b) return `[S88fixed] { [int16](([int32](a.val)*[int32](b.val))>> 8) } end)
meta.__div = macro(function (a, b) return `[S88fixed] { [int16]( [int32](a.val)*256 / b.val) } end)
meta.__mod = macro(function (a, b) return `[S88fixed] { a.val % b.val } end)
meta.__unm = macro(function (a) return `[S88fixed] { -a.val } end)
meta.__lt = macro(function (a, b) return `a.val < b.val end)
meta.__le = macro(function (a, b) return `a.val <= b.val end)
meta.__gt = macro(function (a, b) return `a.val > b.val end)
meta.__ge = macro(function (a, b) return `a.val >= b.val end)
meta.__eq = macro(function (a, b) return `a.val == b.val end)
meta.__ne = macro(function (a, b) return `a.val ~= b.val end)

-- You are writing firmware for an embedded system which has extremely limited math capabilities
-- It has no FPU and uses a 16 bit ALU, so any floating point calculation uses softFP and is slow.
-- You need to do a lot of trigonometry for your application,
-- Write an implementation of the sin function which doesn't require an FPU and evaluates quickly.
-- Because this is so important, you have been allocated a whole kilobyte of EPROM to this purpose.
-- Use a look up table to store values of sin for various numbers.
-- You may use either math.sin or the taylor series for sin to compute the LUT.
-- You may linearly interpolate between adjacent values to compute the sin.
-- The LUT must be computed at compile time and not at runtime.
-- Your sin implementation must operate in constant time and dynamically allocate no memory.
-- Instructions you use count against your one kilobyte limit.
-- Your implementation must be accurate to within 1/32.


local sintab = {}

local terra dtof(x: double): S88fixed return [S88fixed](x) end

for x = 0, math.pi + 1/64, 1/64 do -- loop from zero to slightly over pi to build a table of a single half-cycle
	table.insert(sintab, --[[TODO: Compute the sin]])
end

print(#sintab.. " entries in the LUT")


local sinlut = constant(`arrayof(S88fixed, sintab))

terra M.sinfixed(x: S88fixed)
	-- TODO: implement this
	-- use modulus to map the number into 0 to 2 pi
	-- remap negative numbers to positive numbers with equivalent values
	-- compute the sin of x, remember to handle the section from pi to 2 pi which is negative
end

terra M.sindouble(x:double):double return M.sinfixed(x) end

function M.evaluate_sin()
	local totalerr = 0
	for i = 1, 10000 do
		local x = math.random()*8*math.pi - 4*pi -- roundoff error accumulates the farther away from zero it gets.
		local err = math.abs(math.sin(x) - M.sindouble(x))
		if err > 1/32 then
			error("failed to meet accuracy tolerance on try "..i.." on value "..x.." should have been "..math.sin(x).." but was "..M.sindouble(x))
		end
		totalerr = totalerr + err
	end
	return totalerr
end


return M
