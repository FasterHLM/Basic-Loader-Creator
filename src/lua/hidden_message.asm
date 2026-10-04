;appends the hidden message (HiddenStart, HiddenLen) to the TR-DOS image - into the free space
;of the file's last sector, right behind the autostart marker. It is not counted in the file
;length or in the sector count in the catalogue

	lua pass3
	local function define(name)					-- the value of a define, expanded the same way sjasmplus does it
		return load("return " .. sj.get_define(name), name, "t",
			setmetatable({}, {__index = function(_, k) return define(k) end}))()
	end
	local image = assert(io.open(define("OutputName") .. ".trd", "r+b"))
	local wanted = (define("file") .. "        "):sub(1, 8) .. "B"			-- name in the catalogue: 8 characters and the type
	for entry = 1, 128 do					-- catalogue: the first 8 sectors, 16 bytes per file
		local e = image:read(16)
		if e:byte(1) == 0 then break end			-- the catalogue is empty from here on
		if e:sub(1, 9) == wanted then
			local length = e:byte(10) + e:byte(11) * 256		-- length in the catalogue
			local first = (e:byte(16) * 16 + e:byte(15)) * 256	-- first sector: track*16+sector
			local offset = first + length + 4		-- behind the marker #80, #AA and the line number
			assert(image:seek("set", offset), "hidden message - cannot seek in the TR-DOS image")
			local from = sj.get_label("HiddenStart")
			for i = 0, sj.get_label("HiddenLen") - 1 do
				assert(image:write(string.char(sj.get_byte(from + i))), "hidden message - cannot write to the TR-DOS image")
			end
			image:close()
			return
		end
	end
	image:close()
	sj.error("hidden message - file " .. wanted .. " not found on the TR-DOS image")
	endlua