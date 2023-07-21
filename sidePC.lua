local monitor = peripheral.find("monitor")
local modem = peripheral.find("modem")

modem.open(456)  -- 修改为与发送方相同的频道

local function displaySongName(songName)
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("Now Playing:")
    monitor.setCursorPos(1, 2)
    monitor.write(songName)
end

while true do
    local event, side, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
    displaySongName(message)
    -- 执行你想要的操作，比如保存歌曲名到一个文件中
end
