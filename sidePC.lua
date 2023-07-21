local monitor = peripheral.find("monitor")
local screenWidth, screenHeight = monitor.getSize()

-- 创建触摸屏界面
function createInterface()
    -- 清空屏幕
    monitor.clear()

    -- 绘制按钮
    monitor.setCursorPos(1, 1)
    monitor.write("change")

    monitor.setCursorPos(1, 2)
    monitor.write("exit")
end

-- 监听触摸事件
function listenTouchEvents()
    while true do
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")
        if xPos >= 1 and xPos <= 2 then
            if yPos == 1 then
                -- 执行 change 按钮的操作
                changeButtonAction()
            elseif yPos == 2 then
                -- 执行 exit 按钮的操作
                exitButtonAction()
            end
        end
    end
end

-- change 按钮的操作
function changeButtonAction()
    -- 在这里编写 change 按钮的操作代码
    print("Change按钮被点击了！")
end

-- exit 按钮的操作
function exitButtonAction()
    -- 在这里编写 exit 按钮的操作代码
    print("Exit按钮被点击了！")
    return
end

-- 主程序
createInterface()
listenTouchEvents()
