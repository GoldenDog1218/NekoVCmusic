local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
--local monitor = peripheral.find("monitor")
local monitor = peripheral.wrap("left")
local monitor2 = peripheral.wrap("top")
local modem = peripheral.find("modem")
local breakout = false
modem.open(114)
modem.open(514)
local decoder = dfpwm.make_decoder()
monitor2.clearLine(1)
monitor2.clearLine(2)
monitor2.setCursorPos(1, 1)
monitor2.write("Now Playing: ")
monitor2.clearLine(2)
monitor2.setCursorPos(1, 2)
monitor2.write("Nothing")
local MusicPlayer = {}
MusicPlayer.__index = MusicPlayer

function onlinecheck(go, back, message)
	local expectedReply = "online" -- 期望的回复内容

	while true do
		print("sending: " .. message)
		modem.transmit(go, back, message) -- 向指定频道发送消息
		monitor.setCursorPos(1, 1)
		monitor2.setCursorPos(1, 1)
		monitor.write("The auxiliary host is offline. Please start the SidePC program on the auxiliary host.")
		monitor2.write("The auxiliary host is offline. Please start the SidePC program on the auxiliary host.")
		local event, modemSide, senderChannel, 
			  replyChannel, message, senderDistance = os.pullEvent("modem_message")
		-- 等待接收回复消息

		if message == expectedReply then
			break 
		else
			sleep(1) -- 等待一秒后继续发送消息
		end
	end
end

function MusicPlayer.new()
    local self = setmetatable({}, MusicPlayer)
    self.musicList = {}
    return self
end

function MusicPlayer:scanMusicFiles()
    self.musicList = {}
    local files = fs.list("./disk/")
    for _, file in ipairs(files) do
        if not fs.isDir(file) then
            local fileName = fs.getName(file)
            if string.sub(fileName, -6) == ".dfpwm" then
                table.insert(self.musicList, fileName)
            end
        end
    end
end

function MusicPlayer:printMusicList()
    monitor.setTextScale(1)
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("Music List:   (make sure sidePC is on)")
    for i, musicName in ipairs(self.musicList) do
        monitor.setCursorPos(1, i + 1)
        monitor.write(i .. ". " .. musicName)
    end
end

function MusicPlayer:downloadFile(url, path)
    local response = http.get(url)
    if response and response.getResponseCode() == 200 then
        local file = fs.open(path, "w")
        file.write(response.readAll())
        file.close()
        return true
    else
        return false
    end
end

function MusicPlayer:playMusic(musicIndex)
	local breakout = false
    local musicName = self.musicList[musicIndex]
    if musicName then
        local filePath = "./disk/" .. musicName
        if not fs.exists(filePath) then
            local url = "https://raw.githubusercontent.com/GoldenDog1218/NekoVCmusic/main/" .. musicName
            if self:downloadFile(url, filePath) then
                print("Downloaded: " .. musicName)
            else
                print("Failed to download: " .. musicName)
                return
            end
        end
        monitor2.clearLine(1)
        monitor2.clearLine(2)
        monitor2.setCursorPos(1, 1)
        monitor2.write("Now Playing: ")
        monitor2.setCursorPos(1, 2)
        monitor2.write(musicName)
        -- 添加向另一台计算机发送当前歌曲名的代码
        --modem.open(123)
        --modem.open(456)
        --modem.transmit(123, 456, musicName)  -- 修改频道和目标ID

        for chunk in io.lines(filePath, 16 * 1024) do
	        if breakout then
			break
		end
		local buffer = decoder(chunk)
	        while not speaker.playAudio(buffer) do
	        	os.pullEvent("speaker_audio_empty")
			local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
			if message == "ChangeMusic" then
				modem.transmit(514, 114, "VCCAT")
				local breakout = true
				speaker.stop()
				local player = MusicPlayer.new()
				player:start()
			elseif message == "ExitPlz" then
				modem.transmit(514, 114, "VCCAT")
				monitor.clear()
				monitor2.clear()
				speaker.stop()
				exit()
			end
		end
        end
        monitor2.clearLine(2)
        monitor2.setCursorPos(1, 2)
        monitor2.write("Nothing")
    else
        print("Invalid music index")
    end
end

function MusicPlayer:start()
    while true do
        self:scanMusicFiles()
        self:printMusicList()

        print("Enter music index to play or 'exit' to quit:")
        local input = io.read()
        if input == "exit" then
            break
        elseif input == "list" then
            -- Continue to next iteration of the loop to show the music list again
        else
            local musicIndex = tonumber(input)
            if musicIndex then
                self:playMusic(musicIndex)
                print("Press any key to stop the music or 'list' to see the music list:")
                print("(input 'exit' to quit)")
                input = io.read()
                if input == "list" then
                    -- Continue to next iteration of the loop to show the music list again
                else
                    break
                end
            else
                print("Invalid input")
            end
        end
    end

    monitor.clear()
    speaker.stop()
end
--onlinecheck(114, 514,"online")
local player = MusicPlayer.new()
player:start()
