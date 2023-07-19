local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local decoder = dfpwm.make_decoder()
local exie = fyou

function music()
	local monitor = peripheral.find("monitor")
	monitor.setTextScale(1)
	monitor.setCursorPos(1, 1)
	monitor.write("Now Playing...")
	monitor.setCursorPos(4, 2)
	monitor.write("Nothing")
	print("input music name or exit:")
	local musicName = io.read()
	monitor.setCursorPos(4, 2)
	monitor.write(musicName)
	if musicName == "exit" then
		exit()
	end
	local fullname = musicName .. [[.dfpwm]]
	for chunk in io.lines( fullname, 16 * 1024) do
		local buffer = decoder(chunk)
		while not speaker.playAudio(buffer) do
			os.pullEvent("speaker_audio_empty")
			--needexit()
		end
	end
	monitor.setCursorPos(4, 2)
	monitor.write("Nothing")
end
function needexit()
	local exie = io.read()
	if exie == "exit" then
		local exie = fyou
		print("quiting....")
		exit()
	end
	if exie == "change" or exie == "stop" then
		local exie = fyou
		music()
	end
end
while exie ~= "exit" do
music()
print("quit or change music?")
print("(input quit or change)")
needexit()
end