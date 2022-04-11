

--[=[

    This file contains several TODO comments. Fill in the code to complete the TODOs.

    This assignment is set up for incremental testing via the REPL as you complete it.

    To load the code in this assignment, you can run 
    ```
    	at = assert( terralib.loadfile "autotuner.t")()
    ```
    in the repl which will give access to the functions in this file in the namespace at.
    To test one of the implementations, you can run a line like
    ```
    	print(at.evaluate_memcpy(at.memcpy_basic:getpointer()))
    ```
    to print out the time consumed by using the implementation of memcpy on 1024 eight megabyte buffers.
    The time will probably be in microseconds, but that is system dependent.
    The value -1 indicates that the implementation is incorrect.

    Syntax highlighting is useful. Unfortunately Terra does not have much editor support yet.
    Emacs and Vim both have addons for syntax highlighting Terra. i am not aware of other support.

    Due to the small community and young age of the language, the googleability and amount of stack-overflow answers is very small.
    Please contact me for assistance if you are having difficulties.

    The calls at.memcpy_basic:disas() and at.memcpy_basic:printpretty(compactify) will show the code for the functions in the file.
    disas shows both the LLVM IR and the processor specific assembly for the function.
    printpretty will show the generated AST serialized as source code. the compactify parameter changes whether symbols with different
    origins get fused into pretty looking lines discarding the source information or split into separate lines to show origins at expense of output size and legibility.

    In this assignment you will use multistage programming operators to implement a generic and reusable loop unrolling optimization, and then build an autotuner to optimize it.

    https://en.wikipedia.org/wiki/Duff%27s_device

    In C,  an optimized memory to memory copy using Duff's device looks like this. This is a manual loop unrolling. 
    void memcpy(char * to, const char * from, size_t count) {
	size_t n = (count + 7) / 8;
	switch (count % 8) {
            case 0: do { *to++ = *from++;
	    case 7:      *to++ = *from++;
	    case 6:      *to++ = *from++;
	    case 5:      *to++ = *from++;
	    case 4:      *to++ = *from++;
	    case 3:      *to++ = *from++;
	    case 2:      *to++ = *from++;
	    case 1:      *to++ = *from++;
                } while (--n > 0);
        }
    }

    Duff's device is a special technique for unrolling a loop by hand in C.Duff's device is hard to write and maintain by hand,
    so it is a good place to use multistage programming to generate it.
    For simplicity, the implementation of loop unrolling used here will be less sophisticated than Duff's device.

    If your include paths are in a strange location, for instance if you are using Windows, you may need to add a line of code
    ```
	terralib.includepath = [[path to your include files; additional paths for include files]]
    ```
    to direct terra to the correct directory.

]=]


-- Get some useful libraries
local C = terralib.includecstring [[
#include <stdio.h>
#include <malloc.h>
#include <time.h>

]]

local M = {}

-- Check if disabling optimizations are supported and try to disable them
-- This only works on the latest build from source and not the binary release
-- Disabling LLVM's optimizations will make the effects of the unrolling more obvious and predictable
-- LLVM is good at optimizing these toy examples so the effect of the unrolling gets hidden a bit
local function deoptimize(fn)
	if fn.setoptimized then
		fn:setoptimized(false)
	end
	return fn
end

-- A simple implementation of memcopy that doesn't use unrolling optimizations
-- Unfortunately LLVM is already pretty good at unrolling this and :setoptimized(false) doesn't exist in the latest binary
-- so this is much faster than it should be as a starting point
terra M.memcpy_basic(dest: &opaque, src: &opaque, size: intptr)
	for i = 0, size do
		@([&uint8](dest) + i) = @([&uint8](src) + i)
	end
end

deoptimize(M.memcpy_basic)

-- Evaluate the performance of a particular memcpy implementation. This tries to copy a large buffer and times the operation.
terra M.evaluate_memcpy(cpyfn: {&opaque, &opaque, intptr} -> {})
	var start_time: C.clock_t
	var end_time: C.clock_t

	var size = 8 * 1024 * 1024
	var buff = [&uint8](C.malloc(size))
	var dest = [&uint8](C.malloc(size))

	for i = 0, size do
		buff[i] = i % 256
	end

	start_time = C.clock()
	for i = 1, 1024 do cpyfn(dest, buff, size) end
	end_time = C.clock()

	for i = 0, size do
		if dest[i] ~= i % 256 then
			return -1
		end
	end

	C.free(buff)
	C.free(dest)

	return end_time - start_time
end

-- alpha times x plus y.
-- This is a generic function that will work for any numeric type
-- The lua function creates a specialized terra function for the type
local function axpy_basic(num)
	local terra axpy_basic_impl(dest: &num, a: num, x: &num, y: &num, count: intptr)
		for i = 0, count do
			dest[i]= a * x[i] + y[i]
		end
	end
	return deoptimize(axpy_basic_impl)
end
-- memoize it so that it doesn't need to recompile if invoked for the same type
M.axpy_basic = terralib.memoize(axpy_basic)

M.saxpy_basic = M.axpy_basic(float)

-- Evaluate the performance of an axpy implementation. This implementation is also a generic function.
local function evaluate_axpy(num)
	local terra evaluate_axpy_impl(axpyfn: {&num, num, &num, &num, intptr} -> {})
		var start_time: C.clock_t
		var end_time: C.clock_t

		var numelems = 1024 * 1024
		var size = terralib.sizeof(num) * numelems
		var xbuff = [&num](C.malloc(size))
		var ybuff = [&num](C.malloc(size))
		var dest  = [&num](C.malloc(size))

		for i = 0, numelems do
			xbuff[i] = i % 256
			ybuff[i] = i / 256 % 256
		end

		start_time = C.clock()
		--TODO: write code that invokes the axpyfn on the provided buffers with alpha=4 1024 times
		end_time = C.clock()

		for i = 0, numelems do
			if dest[i] ~= 4 * (i % 256) + (i / 256 % 256) then
				return -1
			end
		end

		C.free(xbuff)
		C.free(ybuff)
		C.free(dest)

		return end_time - start_time
	end
	return evaluate_axpy_impl
end
M.evaluate_axpy = terralib.memoize(evaluate_axpy)

-- Now, we can unroll the loop.
-- Basic implementation of memcpy

terra M.memcpy_manunr(dest : &opaque, src : &opaque, size : intptr)
	for i = 0, size / 8 do
		[&uint8](dest)[8*i] = [&uint8](src)[8*i]
		[&uint8](dest)[8*i + 1] = [&uint8](src)[8*i + 1]
		[&uint8](dest)[8*i + 2] = [&uint8](src)[8*i + 2]
		[&uint8](dest)[8*i + 3] = [&uint8](src)[8*i + 3]
		[&uint8](dest)[8*i + 4] = [&uint8](src)[8*i + 4]
		[&uint8](dest)[8*i + 5] = [&uint8](src)[8*i + 5]
		[&uint8](dest)[8*i + 6] = [&uint8](src)[8*i + 6]
		[&uint8](dest)[8*i + 7] = [&uint8](src)[8*i + 7]
	end
	for i = (size / 8) * 8, size do
		[&uint8](dest)[i] = [&uint8](src)[i]
	end
end
deoptimize(M.memcpy_manunr)
-- That was a lot of copy-paste coding. It is fragile, resistent to change, and looks ugly
-- Let's improve that.

-- Instead, we can build a function that implements the unrolling expansion automatically.
-- We can then have it automatically do the expansion for us, making the code easier to read and update.

-- Implement unrolling.
-- arguments:
--   a number for the amount of unrolling it should do,
--   a symbol for the run-time count of the loop.
--   a body function which generates one step of the body given an index expression
-- you can use `a + b as a way to create an expression quote easily
local function unrolledloop(unroll, count, body)
	return quote
		var rollcount = count / unroll
		for i = 0, rollcount do
			escape
				for offset = 0, unroll-1 do
					emit(body(0 --[[TODO: write the index expression]]))
				end
			end
		end
		for i = rollcount * unroll, count do
			[body(0 --[[TODO: write the index expression]])]
		end
	end
end

-- Using that implementation, making a duff's device optimized version of a loop gets much easier
terra M.memcpy_unr8(dest: &opaque, src: &opaque, size: intptr)
	[unrolledloop(8, size, function(idx)
		return quote ([&uint8](dest))[idx] = ([&uint8](src))[idx] end
	end)]
end
deoptimize(M.memcpy_unr8)

-- Similarly, we can optimize the axpy functions with the same technique
local function axpy_duff8(num)
	local terra axpy_duff8_impl(dest: &num, a: num, x: &num, b: &num, count: intptr)
		[unrolledloop(8, count, function(idx)
			--TODO: Write this loop body
		end)]
	end
	return deoptimize(axpy_duff8_impl)
end


--But why stop there?
--Now that we have a way to procedurally generate an unrolling with a particular size,
--we can just try a bunch of different unroll sizes and see which one is the fastest.

--In fact, we can automate the process.


-- Initial implementation of the autotuner
-- This function takes a generator function, an evaluation function, and a range of parameters.
-- It calls the generator with every parameter in the range, and evaluates the generated function.
-- It returns the function with the best (lowest) score produced by the generator

local function autotune(generate, evaluate, min, max)
	local function runtest(param)
		local fn = generate(param)
		local score = evaluate(fn:getpointer())
		return score, fn
	end
	-- TODO: Write the body of this function.
	-- loop from min to max and minimize the score of runtest
	-- return the best function
end

-- Use the autotuner to produce an optimized version of memcpy.
-- uncomment when ready to start on this section
--[=[
M.memcpy_tuned = autotune(
	function(unroll)
		local terra memcpy_tuned_impl(dest: &opaque, src: &opaque, size: intptr)
			[unrolledloop(unroll, size, function(idx)
				return quote ([&uint8](dest))[idx] = ([&uint8](src))[idx] end
			end)]
		end
		return deoptimize(memcpy_tuned_impl)
	end,
	M.evaluate_memcpy,
	--[[TODO: write some bounds]])

--Use the autotuner to produce an optimized version of axpy for whatever type is given to it
local function axpy_tuned(num)
	return autotune(
		function(unroll)
			local terra axpy_tuned_impl(dest: &num, a: num, x: &num, b: &num, count: intptr)
				--TODO: Write the body of this function
			end
			return deoptimize(axpy_tuned_impl)
		end,
		M.evaluate_axpy(num),
		--[[TODO: write some bounds]])
end
M.axpy_tuned = terralib.memoize(axpy_tuned)
--]=]

M.C = C

return M
