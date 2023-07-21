local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local monitor1 = peripheral.find("monitor", function(name, object) return object.isPrimary() end) -- 左侧屏幕
local monitor2 = peripheral.find("monitor", function(name, object) return not object.isPrimary() end) -- 右侧屏幕

local decoder = dfpwm.make_decoder()

local MusicPlayer = {}
MusicPlayer.__index = MusicPlayer

function MusicPlayer.new()
    local self = setmetatable({}, MusicPlayer)
    self.musicList = {}
    return self
end

function MusicPlayer:scanMusicFiles()
    self.musicList = {}
    local files = fs.list("./disk/") -- 扫描磁盘根目录下的文件
    for _, file in ipairs(files) do
        if not fs.isDir(file) then
            local fileName = fs.getName(file)
            if string.sub(fileName, -6) == ".dfpwm" then
                table.insert(self.musicList, fileName) -- 将符合条件的音乐文件名添加到音乐列表中
            end
        end
    end
end

function MusicPlayer:printMusicList()
    monitor1.clear()
    monitor1.setCursorPos(1, 1)
    monitor1.write("Music List:") -- 显示标题

    for i, musicName in ipairs(self.musicList) do
        monitor1.setCursorPos(1, i + 1)
        monitor1.write(i .. ". " .. musicName) -- 显示音乐列表
    end
end

function MusicPlayer:printPlayState(state)
    monitor2.clear()
    monitor2.setCursorPos(1, 1)
    monitor2.write("Now Playing: ") -- 显示标题

    if state then
        monitor2.setCursorPos(1, 2)
        monitor2.write("Playing") -- 显示正在播放
    else
        monitor2.setCursorPos(1, 2)
        monitor2.write("Paused") -- 显示暂停
    end
end

function MusicPlayer:downloadFile(url, path)
    local response = http.get(url) -- 下载音乐文件
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
    local musicName = self.musicList[musicIndex]
    if musicName then
        local filePath = "./disk/" .. musicName
        if not fs.exists(filePath) then
            local url = "https://raw.githubusercontent.com/GoldenDog1218/NekoVCmusic/main/" .. musicName
            if self:downloadFile(url, filePath) then
                print("Downloaded: " .. musicName) -- 下载音乐文件成功
            else
                print("Failed to download: " .. musicName) -- 下载音乐文件失败
                return
            end
        end

        self:printPlayState(true) -- 显示播放状态为正在播放

        for chunk in io.lines(filePath, 16 * 1024) do
            local buffer = decoder(chunk)
            while not speaker.playAudio(buffer) do
                os.pullEvent("speaker_audio_empty")
            end
        end
    else
        print("Invalid music index") -- 音乐索引无效
    end
end

function MusicPlayer:start()
    while true do
        self:scanMusicFiles() -- 扫描音乐文件
        self:printMusicList() -- 显示音乐列表

        print("Enter music index to play or 'exit' to quit:")
        local input = io.read()
        if input == "exit" then
            break -- 退出循环，结束音乐播放器
        elseif input == "list" then
            -- 继续下一轮循环显示音乐列表
        else
            local musicIndex = tonumber(input)
            if musicIndex then
                self:playMusic(musicIndex) -- 播放选定的音乐
                self:printPlayState(false) -- 显示播放状态为暂停
                print("Press any key to stop the music or 'list' to see the music list:")
                print("(input 'exit' to quit)")
                input = io.read()
                if input == "list" then
                    -- 继续下一轮循环显示音乐列表
                else
                    break -- 退出循环，结束音乐播放器
                end
            else
                print("Invalid input") -- 输入无效
            end
        end
    end

    monitor1.clear()
    monitor2.clear()
    speaker.stop()
end

local player = MusicPlayer.new()
player:start()
