

-- Converting between values of an enumeration and their string representations is something that can take a lot of code writing even though it is very well patterned.
-- Writing a CSV to struct parser is another thing which can take a lot of coding which is highly patterned.

-- In this exercise, you will write a code generator which will produce efficient code to
--  - convert between string values and enumerated integers
--  - serialize and deserialize a CSV format.

-- An enumeration will be a struct containing a single member of an integer type with methods to convert to and from strings.
-- There will be a function to produce an enumeration from a table of the strings of the enumerations values.

-- The CSV codec will be a function that will read the fields of the type and produce methods on the type which read and write to CSV.
-- The types of the fields of the struct are restricted to be either numeric types or enumerations.

--[[
    To load this file into the repl and run tests on it, use something like
    ```
    pat = assert(terralib.loadfile("patterns.t"))()
    print(pat.days.methods.fromstring)
    print(pat.clientdata.methods.decodeCSV)
    cv = pat.clientData.decodeCSVList(pat.csvData)
    print(cv:size())
    print(cv.get(0).revenue)
    ```

    `pat = require "patterns"` can also work but requires restarting the repl on each edit because `require`d files are cached.
]]

local M = {}

-- Given a map from strings to values, construct a trie aka prefix tree of it.
local function makeTrie(map)
	local root = {children = {}, value = nil}
	for s, value in pairs(map) do
		local node = root
		for i = 1, #s do
			local c = s:sub(i, i)
			node.children[c] = node.children[c] or {children = {}, value = nil}
			node = node.children[c]
		end
		node.value = value
	end
	return root
end

-- Generate code for an FSA matching against a trie/prefix tree where the stored values are terra constants.
local function generateTrieMatcher(trie, str, resvar)
	return quote
		escape
			if trie.value then
				-- accept end of string
				emit quote
					if @str == [int8](0) then
						-- store result
						resvar = trie.value
					end
				end
			end
			-- nest all subtrie tests for successive characters.
			for char, subtrie in pairs(trie.children) do
				emit quote
					-- these are sequential checks. the implementation can be made faster
					-- by binary search for logarithmic time or any constant time lookup.
					if @str == [int8]([string.byte(char)]) then
						str = str + 1
						[generateTrieMatcher(subtrie, str, resvar)]
					end
				end
			end
		end
	end
end

-- Create an enumeration with an optional name and values
function M.enumeration(name, values)
	if not values then values, name = name, nil end -- name is an optional argument
	if not name then name = "enum" end -- default name

	-- Create the struct and add the field.
	local enum = terralib.types.newstruct(name)
	enum.entries[1] = {field = "val", type = int}
	enum.ismyenum = true -- tag it so we can test for them later.

	--TODO: Any preprocessing of the list of values required for your implementation
	local map = {}
	for i, s in ipairs(values) do
		map[s] = i - 1
	end
	local trie = makeTrie(map)

	terra enum.methods.fromstring(str: &int8): enum -- strings are just null terminated byte arrays, just like in C.
		--TODO: implement this function
		-- Basic implementation: Sequentially test equality for each string in the list and choose the index of the matching one.
		-- Intermediate implementation: sort the list and generate comparison instructions in the form of a binary search of the list.
		-- Advanced implementation: Create a finite state automaton which checks against all the strings in a single pass.
		--   This is doable by creating a trie of the strings at compile time and then traversing the trie to compile a search at each node
		--   Time complexity at runtime: O(m + log n) or O(m) depending on implementation where m is length of the string and n is the number of enumerated strings.
		-- Advanced implementation: Perfect hashing. At compile time, try a bunch of different hash functions.
		--   Find one which puts each source string into its own bucket w/o probing and build the hashtable as a compile time constant.
		--   Time complexity at runtime: O(m) where m is the length of the string.
		-- Extra credit for making smarter and faster implementations.

		var res = -1
		-- code goes here
		return [enum] {res}
	end

	local strings = constant((&int8)[#values], `arrayof([&int8], [values]))
	--TODO: any preprocessing for the tostring
	terra enum:tostring(): &int8 -- Produce a string literal of the name of the enumerated value
		--TODO: implement this function
		-- Possible implementations:
		--  - sequentially check each possible value and return the string literal
		--  - index an array of string literals

		-- Check for invalid values in the enumeration.
		if self.val < 0 or self.val > [#values] then
			return "**INVALID**"
		end

		-- code goes here
		return "result"
	end

	return enum
end

M.enumeration = terralib.memoize(M.enumeration)

local std = require 'std' -- atoi, printf, scanf, and friends will be useful.

local basicDecode = {
	[int] = "%d",
	[double] = "%lf",
	[float] = "%f",
	[int64] = "%Ld",
	[int16] = "%hd",
}

-- It would be better to do this with a custom parser which does not use scanf.
-- The code would run faster and more efficiently.
-- However, writing the scanf string is easier than writing a custom parser.
-- synthesize the decoding operations for a type.
-- This function returns a list of initialization code, a string of scanf directives, a list of arguments to scanf, and a list of cleanup code.
local function synthesizeDecode(type, dest)
	if basicDecode[type] then -- decoding a primitive type
		return {}, basicDecode[type], {`&dest}, {}
	elseif type.ismyenum then -- decode an enumeration
		-- LIMIT: Enumeration names may only have up to 63 characters in them. This is easily expandable.
		-- Extra credit: Expand this to choose a buffer size based on the actual name length of the enumeration it is being generated for
		-- Extra credit: fuse the string buffers into a single memory block with a single malloc/free.
		-- Extra credit: allocate the string buffers on the stack.
		local buff = symbol(&int8, "enum_buff")
		return {quote var [buff] = [&int8](std.malloc(64)) end}, "%63[^, \t\n]", {`[buff]}, {quote dest = type.fromstring(buff);std.free(buff) end }
	elseif type:isstruct() then -- synthesize a composite decoding for a struct of CSV-serializable elements
		local fmts = terralib.newlist{}
		local inits, args, cleanups = terralib.newlist{}, terralib.newlist{}, terralib.newlist{}
		for i, entry in ipairs(type.entries) do
			-- merge the decodings for all the fields in the struct into this encoding
			local init, fmt, arg, cleanup = synthesizeDecode(entry.type, `dest.[entry.field])
			inits:insertall(init)
			fmts:insert(fmt)
			args:insertall(arg)
			cleanups:insertall(cleanup)
		end
		return inits, fmts:concat(" , "), args, cleanups
	else
		error("unable to synthesize a CSV converter for "..tostring(type))
	end
end

-- map of the format directives for supported types
local basicEncode = {
	[int] = "%d",
	[double] = "%lf",
	[float] = "%f",
	[int64] = "%Ld",
	[int16] = "%hd",
}

-- construct the format directive and code snippets for performing an encoding.
local function synthesizeEncode(type, src)
	if basicEncode[type] then -- encode a primitive value
		return {}, basicEncode[type], {`src}, {}
	elseif type.ismyenum then -- encode an enumeration
		return {}, "%s", {`src:tostring()}, {}
	elseif type:isstruct() then -- synthesize an encoding for a struct of CSV-serializable elements
		local fmts = terralib.newlist{}
		local inits, args, cleanups = terralib.newlist{}, terralib.newlist{}, terralib.newlist{}
		for i, entry in ipairs(type.entries) do
			-- merge the encodings for all the fields in the struct into this encoding
			local init, fmt, arg, cleanup = synthesizeEncode(entry.type, `src.[entry.field])
			inits:insertall(init)
			fmts:insert(fmt)
			args:insertall(arg)
			cleanups:insertall(cleanup)
		end
		return inits, fmts:concat(" , "), args, cleanups
	else
		error("unable to synthesize a CSV converter for "..tostring(type))
	end
end

local strlen = terralib.externfunction("strlen", &int8 -> intptr)

function M.CSVSerializable(type)
	
	local fieldinfo = {} -- store any data about the fields you need.

	for i, v in ipairs(type.entries) do
		-- compute whatever information you need to store
	end

	-- decode a line of CSV into the storage of the struct
	terra type:decodeCSV(line: &int8)
		escape
			local init, fmt, arg, cleanup = synthesizeDecode(type, self)
			fmt = " "..fmt.."\n%n"
			local consumed = symbol(int, "consumed")
			arg:insert(`&consumed)
			local body = quote 
				var [consumed]
				init
				-- scan the line using the generated format string, into the constructed argument list
				var res = std.sscanf(line, [" "..fmt.."\n"], [arg])
				cleanup
				if res == [#arg - 1] then
					return consumed
				else
					return -1
				end
			end
			emit(body)
			--print(body)
		end
	end

	terra type.decodeCSVList(block: &int8): &std.Vector(type)
		var vect = [std.Vector(type)].alloc()
		vect:init()
		var decres: int = 0
		--std.printf("entering loop\n")
		repeat
			block = block + decres
			--std.printf("remaining block %s\n", block)
			decres = vect:insert():decodeCSV(block)
		until decres <= 0
		--std.printf("Reached the end of the loop\n")
		vect:remove()
		return vect
	end

	-- encode a stored struct into a line of CSV
	terra type:encodeCSV() : &int8
		escape
			local init, fmt, arg, cleanup = synthesizeEncode(type, self)
			emit quote
				init
				-- figure out how large the buffer needs to be
				var size = std.snprintf(nil, 0, [fmt.."\n"], [arg])
				-- check for error conditions
				if size <= 0 then
					cleanup
					std.printf("size: %d was not positive", size)
					return nil
				end
				-- create the buffer
				var buff = [&int8](std.malloc(size))
				-- format the struct into the linebuffer
				var res
				-- TODO, use snprintf to write into the buffer
				cleanup
				-- check for error conditions.
				if res ~= size then
					std.printf("res: %d is not equal to size: %d", res, size)
					return nil
				end
				return buff
			end
		end
	end

	terra type.encodeCSVList(vect: &std.Vector(type))
		var strs: std.Vector(&int8)
		strs:init(vect:size())
		var totlen = 0
		for i = 0, vect:size() do
			@strs:get(i) = vect:get(i):encodeCSV()
			totlen = totlen + strlen(@strs:get(i))
		end
		var resbuf = [&int8](std.malloc(totlen + 1))
		var buffpos = 0
		for stridx = 0, strs:size() do
			var strptr = @strs:get(stridx)
			
			while @strptr ~= 0 do
				resbuf[buffpos] = @strptr
				buffpos = buffpos + 1
			end
		end
		resbuf[buffpos] = 0
		for i = 0, strs:size() do
			std.free(@strs:get(i))
		end
		strs:destruct()
	end


end

-- create an enumeration of days of the week.
M.days = M.enumeration("days", {"sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"})

-- create a struct to store some example data

struct M.clientData {
	dayOfWeek: M.days
	numClients: int
	revenue: int
}
M.CSVSerializable(M.clientData)

M.CSVdata =
[[monday, 120, 450
tuesday, 130, 520
wednesday, 100, 300
thursday, 110, 400
friday, 160, 590
saturday, 200, 640
sunday, 190, 650]]

-- TODO: locate a CSV file and use this tool to parse it and perform a simple operation, like column mean, on it.

return M
