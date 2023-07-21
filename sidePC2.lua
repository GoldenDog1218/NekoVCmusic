local buttonWidth = 8
local buttonHeight = 3
local screenWidth, screenHeight = term.getSize()
local monitor = peripheral.wrap("top")

-- 计算按钮位置
local buttonY = math.floor(screenHeight / 2 - buttonHeight / 2)
local changeButtonX = math.floor(screenWidth / 2 - buttonWidth / 2)
local exitButtonX = changeButtonX + buttonWidth + 2

-- 清空显示屏并绘制按钮
monitor.clear()
monitor.setCursorPos(changeButtonX, buttonY)
monitor.write("[ Change ]")
monitor.setCursorPos(exitButtonX, buttonY)
monitor.write("[ Exit ]")

-- 监听触摸事件
while true do
    local event, side, xPos, yPos = os.pullEvent("monitor_touch")
    
    -- 判断触摸位置是否在按钮范围内
    if yPos == buttonY and xPos >= changeButtonX and xPos < changeButtonX + buttonWidth then
        -- Change按钮被点击，执行相应代码
        -- TODO: 在这里添加Change按钮的代码逻辑
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("Now you can change music")
        sleep(2)
        -- 返回原始界面
        monitor.clear()
        monitor.setCursorPos(changeButtonX, buttonY)
        monitor.write("[ Change ]")
        monitor.setCursorPos(exitButtonX, buttonY)
        monitor.write("[ Exit ]")
    elseif yPos == buttonY and xPos >= exitButtonX and xPos < exitButtonX + buttonWidth then
        -- Exit按钮被点击，执行相应代码
        -- TODO: 在这里添加Exit按钮的代码逻辑
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("Quiting.........")
        sleep(2)
        break  -- 退出程序
    end
end
