meta.name = 'Spelunky 2 Twitch Integration'
meta.version = 'wip'
meta.description = 'Twitch Integration for Spelunky 2'
meta.author = 'pigcow'
meta.unsafe = true


-- load the action script
parse_scr = require 'Data.parse'


-- get the file location
file = os.getenv("TEMP") .. "\\spelunky2TwitchLog.txt"
io.open(file,"w")
io.close()


-- get the initial amount of lines
line_amt = 0
for msg in io.lines(file) do
	line_amt = line_amt + 1
end

set_global_interval(function()
	
	local ctr = 0
	for msg in io.lines(file) do
		ctr = ctr + 1
		if ctr > line_amt then
			line_amt = line_amt + 1
			
			local divider = string.find(msg, ":")
			local msg_name = string.sub(msg, 1, divider-1)
			local msg_data = string.sub(msg, divider+1, -1)
			
			parse_scr.parse_chat(msg_name, msg_data)
			
		end
	end

end, 1)