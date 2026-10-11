;converts the TR-DOS disk image named by the define TrdImage into an SCL image next to it (same name, .scl).
;sjasmplus has no SAVESCL, so this runs as a Lua step on the last pass, after the last savetrd has written the .trd.
;needs a sjasmplus built with Lua (the official builds are)
;
;SCL keeps the catalogue entries (first 14 of 16 bytes each) and the file sectors back to back, then a 32-bit sum of
;all the bytes before it. the disk label, the free-sector counters and deleted files are not carried over.
;
;	define TrdImage "build/" .. project .. version .. ".trd"	;the define may be an expression over other defines
;	include "lib/trd2scl.asm"

	lua pass3
	local function define(name)				-- the value of a define, expanded the same way sjasmplus does it
		return load("return " .. sj.get_define(name), name, "t",
			setmetatable({}, {__index = function(_, k) return define(k) end}))()
	end
	local trdName = define("TrdImage")
	local sclName = trdName:gsub("%.[Tt][Rr][Dd]$", ".scl")
	assert(sclName ~= trdName, "trd2scl - TrdImage must end with .trd: " .. trdName)
	local f = assert(io.open(trdName, "rb"))
	local trd = f:read("a")
	f:close()
	assert(#trd >= 9 * 256, "trd2scl - not a TR-DOS image: " .. trdName)
	local entries = {}
	for i = 0, 127 do				-- catalogue: the first 8 sectors, 16 bytes per file
		local e = trd:sub(i * 16 + 1, i * 16 + 16)
		local first = e:byte(1)
		if first == 0 then break end			-- 0 - the catalogue ends here
		if first ~= 1 then entries[#entries + 1] = e end	-- 1 - deleted file
	end
	local parts = {"SINCLAIR", string.char(#entries)}
	for _, e in ipairs(entries) do parts[#parts + 1] = e:sub(1, 14) end
	for _, e in ipairs(entries) do
		local from = (e:byte(16) * 16 + e:byte(15)) * 256	-- first track * 16 + first sector
		local len = e:byte(14) * 256			-- sectors * 256
		assert(from + len <= #trd, "trd2scl - catalogue entry points outside the image: " .. trdName)
		parts[#parts + 1] = trd:sub(from + 1, from + len)
	end
	local body = table.concat(parts)
	local sum = 0
	for i = 1, #body do sum = sum + body:byte(i) end
	local out = assert(io.open(sclName, "wb"))
	assert(out:write(body, string.pack("<I4", sum & 0xFFFFFFFF)))
	out:close()
	endlua
