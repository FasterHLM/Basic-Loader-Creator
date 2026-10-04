;define BuildDate - the build date "DD.MM.YYYY" from __DATE__ ("YYYY-MM-DD")

	lua allpass
	local y, m, d = string.match(sj.get_define("__DATE__"), "(%d+)-(%d+)-(%d+)")
	sj.insert_define("BuildDate", '"' .. d .. "." .. m .. "." .. y .. '"')
	endlua