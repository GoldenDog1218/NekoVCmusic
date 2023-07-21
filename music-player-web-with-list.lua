local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local decoder = dfpwm.make_decoder()
local exie = fyou
function getFolderFileList(folderPath)
    local fileList = {}
    local folder = io.popen("dir /b \""..folderPath.."\"")
    for fileName in folder:lines() do
        table.insert(fileList, fileName)
    end
    folder:close()
    return fileList
end
function listmusic()
	for i, fileList in ipairs(list) do
	  print(i .. "." .. fileList)
	end
end
function file_exists(path)
	local file = io.open(path, "rb")
	if file then
		file:close()
	end
	return file ~=nil
end
function downloadFile(url, path)
    local response = http.get(url)
    if response then
        local file = fs.open(path, "w")
        file.write(response.readAll())
        file.close()
        
        print("finish:" .. path)
    else
        print("failed:" .. url)
    end
end
function music()
	local monitor = peripheral.find("monitor")
	monitor.setTextScale(1)
	monitor.setCursorPos(39, 4)
	monitor.write("Now Playing...")
	monitor.setCursorPos(39, 5)
	monitor.write("Nothing")
	print("input music name or exit:")
	print("you can input list to show music name")
	local musicName = io.read()
	monitor.setCursorPos(39, 5)
	monitor.clearLine()
	listmusic()
	musiclistnum = listmusic[musicname]
	monitor.write(musiclistnum)
	if musicName == "exit" then
		monitor.clear()
		speaker.stop()
		exit()
	end
	if musicName == "list" then
		monitor.clear()
		listmusic()
		monitor.setTextScale(1)
		monitor.setCursorPos(39, 4)
		monitor.write("Now Playing...")
		monitor.setCursorPos(39, 5)
		monitor.write("Nothing")
		music()
	end
	if file_exists([[./disk/]] .. musiclistnum .. [[.dfpwm]]) then
		local fullname = [[./disk/]] .. musiclistnum .. [[.dfpwm]]
		for chunk in io.lines( fullname, 16 * 1024) do
			local buffer = decoder(chunk)
			while not speaker.playAudio(buffer) do
				os.pullEvent("speaker_audio_empty")
			end
		end
	else 
		local fullname = [[./disk/]] .. musiclistnum .. [[.dfpwm]]
		local url = "https://raw.githubusercontent.com/GoldenDog1218/NekoVCmusic/main/" .. fullname
		downloadFile(url, fullname)
		local fullname = [[./disk/]] .. musiclistnum .. [[.dfpwm]]
		for chunk in io.lines( fullname, 16 * 1024) do
			local buffer = decoder(chunk)
			while not speaker.playAudio(buffer) do
				os.pullEvent("speaker_audio_empty")
			end
		end
	end
	monitor.setCursorPos(4, 2)
	monitor.clearLine()
	monitor.write("Nothing")
end
function needexit()
	print("you can change or stop music")
	local exie = io.read()
	if exie == "quit" then
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