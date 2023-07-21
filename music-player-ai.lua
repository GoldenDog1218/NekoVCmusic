local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local monitor = peripheral.find("monitor")

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
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("Music List:")
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

        monitor.clearLine(5)
        monitor.setCursorPos(1, 5)
        monitor.write("Now Playing: " .. musicName)

        for chunk in io.lines(filePath, 16 * 1024) do
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