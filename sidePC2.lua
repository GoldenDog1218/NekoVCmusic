local monitor = peripheral.find("monitor")
local screenWidth, screenHeight = monitor.getSize()

-- 创建触摸屏界面
function createInterface()
    -- 清空屏幕
    monitor.clear()

    -- 计算按钮位置
    local buttonWidth = 6
    local buttonHeight = 3
    
    local centerX = math.floor(screenWidth / 2)
    local centerY = math.floor(screenHeight / 2)
    
    local changeButtonX = centerX - math.floor(buttonWidth / 2)
    local changeButtonY = centerY - buttonHeight - 1
    
    local exitButtonX = centerX - math.floor(buttonWidth / 2)
    local exitButtonY = centerY + 1

    -- 绘制按钮
    monitor.setCursorPos(changeButtonX, changeButtonY)
    monitor.write("change")

    monitor.setCursorPos(exitButtonX, exitButtonY)
    monitor.write("exit")
end

-- 监听触摸事件
function listenTouchEvents()
    while true do
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")
        if xPos >= changeButtonX and xPos <= (changeButtonX + buttonWidth - 1) then
            if yPos == changeButtonY then
                -- 执行 change 按钮的操作
                changeButtonAction()
            elseif yPos == exitButtonY then
                -- 执行 exit 按钮的操作
                exitButtonAction()
            end
        end
    end
end

-- change 按钮的操作
function changeButtonAction()
    -- 在这里编写 change 按钮的操作代码
    print("Change!")
end

-- exit 按钮的操作
function exitButtonAction()
    -- 在这里编写 exit 按钮的操作代码
    print("Exit!")
    return
end

-- 主程序
createInterface()
listenTouchEvents()
