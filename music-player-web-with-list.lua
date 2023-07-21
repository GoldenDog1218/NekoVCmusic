local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local decoder = dfpwm.make_decoder()
local exie = fyou
local monitor = peripheral.find("monitor")
function getFilesWithExtension(folderPath, extension)
    local fileList = {}
    
    -- 获取文件夹下所有文件和文件夹
    local files = fs.list(folderPath)
    
    -- 遍历每个文件或文件夹
    for _, file in ipairs(files) do
        -- 检查是否为文件
        if fs.isDir(file) == false then
            local fileName = fs.getName(file)
            
            -- 检查文件名是否以指定扩展名结尾
            if string.sub(fileName, -string.len(extension)) == extension then
                -- 将符合条件的文件名添加到列表中
                table.insert(fileList, fileName)
            end
        end
    end
    
    return fileList
end
function listmusic()
	local monitor = peripheral.find("monitor")
	local fileList = getFilesWithExtension("./disk/", ".dfpwm")
	monitor.setCursorPos(1, 0)
	monitor.write("music list")
	for i, fileList in ipairs(fileList) do
	  print(i .. "." .. fileList)
	  monitor.write(i .. "." .. fileList)
	  monitor.setCursorPos(1+i, 0)
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
	monitor.setCursorPos(29, 4)
	monitor.write("Now Playing...")
	monitor.setCursorPos(29, 5)
	monitor.write("Nothing")
	print("input music ID or exit:")
	print("you can input list to show music name with ID")
	local musicName = io.read()
	monitor.setCursorPos(29, 5)
	monitor.clearLine()
	local fileList = getFilesWithExtension("./disk/", ".dfpwm")
	monitor.setCursorPos(1, 0)
	monitor.write("music list")
	for i, fileList in ipairs(fileList) do
	  print(i .. "." .. fileList)
	  monitor.write(i .. "." .. fileList)
	  monitor.setCursorPos(1+i, 0)
	end
	local musicList = getFilesWithExtension("./disk/", ".dfpwm")
	local musiclistnum = musicList[musicname]
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
		monitor.setCursorPos(29, 4)
		monitor.write("Now Playing...")
		monitor.setCursorPos(29, 5)
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