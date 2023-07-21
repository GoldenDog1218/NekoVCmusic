local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local monitor = peripheral.find("monitor")

local decoder = dfpwm.make_decoder()

local MusicPlayer = {}
MusicPlayer.__index = MusicPlayer

function MusicPlayer.new()
    local self = setmetatable({}, MusicPlayer)
    self.musicList = {}
    self.diskDriveList = {"bottom", "top", "back"} -- 改为你的磁盘驱动器列表
    return self
end

function MusicPlayer:scanMusicFiles()
    self.musicList = {}
    for _, drive in ipairs(self.diskDriveList) do
        if peripheral.isPresent(drive) and peripheral.getType(drive) == "drive" then
            local files = fs.list(drive.."/disk/")
            for _, file in ipairs(files) do
                if not fs.isDir(drive.."/disk/"..file) then
                    local fileName = fs.getName(file)
                    if string.sub(fileName, -6) == ".dfpwm" then
                        table.insert(self.musicList, drive.."/disk/"..fileName)
                    end
                end
            end
        end
    end
end

function MusicPlayer:printMusicList()
    monitor.setTextScale(1)
    monitor.clear()
    
    local width, height = monitor.getSize()
    
    -- 列表标题
    monitor.setCursorPos(1, 1)
    monitor.write("Music List:")
    
    -- 显示音乐列表
    for i, musicPath in ipairs(self.musicList) do
        if i <= height - 1 then  -- 减去标题占据的行数
            monitor.setCursorPos(1, i + 1)
            local musicName = fs.getName(musicPath)
            monitor.write(i .. ". " .. musicName)
        else
            break  -- 超过显示屏高度时停止显示
        end
    end
end

function MusicPlayer:downloadFile(url, path)
    -- 略去下载文件的代码，与原始代码相同
end

function MusicPlayer:playMusic(musicIndex)
    local musicPath = self.musicList[musicIndex]
    if musicPath then
        local fileName = fs.getName(musicPath)

        monitor.clearLine(5)
        monitor.setCursorPos(1, 5)
        monitor.write("Now Playing: " .. fileName)

        local drive = string.match(musicPath, "(%a+)/disk/")
        for chunk in io.lines(drive.."/disk/"..fileName, 16 * 1024) do
            local buffer = decoder(chunk)
            while not speaker.playAudio(buffer) do
                os.pullEvent("speaker_audio_empty")
            end
        end
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

local player = MusicPlayer.new()
player:start()
