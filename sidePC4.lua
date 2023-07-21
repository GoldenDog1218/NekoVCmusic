local buttonWidth = 2
local buttonHeight = 1
local monitor = peripheral.find("monitor")
local screenWidth, screenHeight = monitor.getSize()
local midpos = math.floor(screenWidth / 2)
local modem = peripheral.find("modem")
modem.open(114)
modem.open(514)
function send(go, back, message)
	local expectedReply = "ok" -- 期望的回复内容
	local message = "change" -- 要发送的消息

	while true do
		print("sending: " .. message)
		modem.transmit(go, back, message) -- 向指定频道发送消息

		local event, modemSide, senderChannel, 
			  replyChannel, message, senderDistance = os.pullEvent("modem_message")
		-- 等待接收回复消息

		if message == expectedReply then
			print("get it: " .. message)
			break -- 收到期望的回复，跳出循环
		else
			print("not this one " .. message)
			sleep(1) -- 等待一秒后继续发送消息
		end
	end
end
-- 计算按钮位置
local buttonY = math.floor(screenHeight / 2 - buttonHeight / 2)
local changeButtonX = 2
local exitButtonX = screenWidth - buttonWidth - 1
monitor.setTextScale(0.7)
-- 清空屏幕并绘制按钮
monitor.clear()
monitor.setCursorPos(changeButtonX, buttonY)
monitor.write("[Change]")
monitor.setCursorPos(exitButtonX, buttonY)
monitor.write("[Exit]")

-- 监听触摸事件
while true do
    local event, side, xPos, yPos = os.pullEvent("monitor_touch")
    -- 判断触摸位置是否在按钮范围内
    if xPos < midpos then
        -- Change按钮被点击，执行相应代码
        -- TODO: 在这里添加Change按钮的代码逻辑
        monitor.clear()
        monitor.setCursorPos(1, 1)
		monitor.write("Please stand by......")
		send(114, 514, "ChangeMusic")
        monitor.write("Now you can change music!")
        sleep(2)
        -- 返回原始界面
        monitor.clear()
        monitor.setCursorPos(changeButtonX, buttonY)
        monitor.write("[Change]")
        monitor.setCursorPos(exitButtonX, buttonY)
        monitor.write("[Exit]")
    elseif xPos > midpos then
        -- Exit按钮被点击，执行相应代码
        -- TODO: 在这里添加Exit按钮的代码逻辑
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("Quiting.....")
		send(114, 514, "ExitPlz")
        sleep(2)
        break  -- 退出程序
    end
end
