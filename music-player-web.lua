local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local decoder = dfpwm.make_decoder()
local exie = fyou

function file_exists(path)
	local file = io.open(path, "rb")
	if file then
		file:close()
	end
	return file ~=nil
end
function downloadFile(url, path)
    -- 获取文件内容
    local response = http.get(url)
    
    -- 如果获取成功
    if response then
        -- 创建文件
        local file = fs.open(path, "w")
        
        -- 写入文件内容
        file.write(response.readAll())
        
        -- 关闭文件
        file.close()
        
        print("finish:" .. path)
    else
        print("failed:" .. url)
    end
end
function music()
	local monitor = peripheral.find("monitor")
	monitor.setTextScale(1)
	monitor.setCursorPos(1, 1)
	monitor.write("Now Playing...")
	monitor.setCursorPos(4, 2)
	monitor.write("Nothing")
	print("input music name or exit:")
	print("if music not exists it will be download")
	local musicName = io.read()
	monitor.setCursorPos(4, 2)
	monitor.write(musicName)
	if musicName == "exit" then
		monitor.clear()
		speaker.stop()
		exit()
	end
	if file_exists(musicName .. [[.dfpwm]]) then
		local fullname = musicName .. [[.dfpwm]]
		for chunk in io.lines( fullname, 16 * 1024) do
			local buffer = decoder(chunk)
			while not speaker.playAudio(buffer) do
				os.pullEvent("speaker_audio_empty")
			end
		end
	else 
		local fullname = musicName .. [[.dfpwm]]
		local url = "https://raw.githubusercontent.com/GoldenDog1218/NekoVCmusic/main/" .. fullname
		downloadFile(url, fullname)
		local fullname = musicName .. [[.dfpwm]]
		for chunk in io.lines( fullname, 16 * 1024) do
			local buffer = decoder(chunk)
			while not speaker.playAudio(buffer) do
				os.pullEvent("speaker_audio_empty")
			end
		end
	end
	monitor.setCursorPos(4, 2)
	monitor.write("Nothing")
end
function needexit()
	print("you can change or stop music")
	local exie = io.read()
	if exie == "exit" then
		local exie = fyou
		speaker.stop()
		print("quiting....")
		monitor.clear()
		exit()
	end
	if exie == "change" or exie == "stop" or exie == " change" or exie == " stop" then
		local exie = fyou
		speaker.stop()
		music()
	end
end
while exie ~= "exit" do
music()
print("quit or change music?")
print("(input quit or change)")
needexit()
end