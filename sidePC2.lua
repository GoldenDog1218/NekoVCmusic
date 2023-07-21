local buttonWidth = 2
local buttonHeight = 1
local screenWidth, screenHeight = term.getSize()

-- 计算按钮位置
local buttonY = math.floor(screenHeight / 2 - buttonHeight / 2)
local changeButtonX = 2
local exitButtonX = screenWidth - buttonWidth - 1

-- 清空屏幕并绘制按钮
term.clear()
term.setCursorPos(changeButtonX, buttonY)
print("Change")
term.setCursorPos(exitButtonX, buttonY)
print("Exit")

-- 监听触摸事件
while true do
    local event, side, xPos, yPos = os.pullEvent("monitor_touch")
    
    -- 判断触摸位置是否在按钮范围内
    if yPos == buttonY and xPos >= changeButtonX and xPos < changeButtonX + buttonWidth then
        -- Change按钮被点击，执行相应代码
        -- TODO: 在这里添加Change按钮的代码逻辑
        print("Change按钮被点击")
    elseif yPos == buttonY and xPos >= exitButtonX and xPos < exitButtonX + buttonWidth then
        -- Exit按钮被点击，执行相应代码
        -- TODO: 在这里添加Exit按钮的代码逻辑
        print("Exit按钮被点击")
        break  -- 退出程序
    end
end
