local monitor = peripheral.find("monitor")
if not monitor then
    error("No monitor found")
end

local modem = peripheral.find("modem")
if not modem then
    error("No modem found")
end

local monitorWidth, monitorHeight = monitor.getSize()

local running = true
local list = {}
local scroll = 0
local selected

local function clear()
    monitor.setBackgroundColor(colors.black)
    
    monitor.clear()
    monitor.setTextScale(0.5)
    monitor.setCursorPos(1,1)

    return
end

function readList()
    local file = fs.open("list.txt","r")
    
    if not file then
        return {}
    end
    
    local data = file.readAll()
    
    file.close()
    
    if data == "" then
        return {}
    end
    
    return textutils.unserialise(data)
end

function saveList()
    local file = fs.open("list.txt", "w")
    
    file.write(textutils.serialise(list))
    
    file.close()
    return
end

local function writeList(list, --[[optional]]index)
    index = index or 0
    
    if not list then
        return
    end
    
    for line = index, index + monitorHeight, 1 do
        monitor.setCursorPos(1, line - index)
        monitor.setBackgroundColor(colors.black)
        monitor.clearLine()

        if line == selected then
            monitor.setBackgroundColor(colors.blue)
        end
        
        monitor.write(list[line])
    end
    
    return
end

local function getPercentScrolled()
    if not list then
        return 0
    end

    local result = scroll * 100 / (#list - monitorHeight)
    
    if result ~= result then
        return 0
    end
    
    return result
end

local function writeScroll()
    monitor.setCursorPos(monitorWidth, 1)
    monitor.write("^")
    
    local y = getPercentScrolled() * (monitorHeight -3) / 100
    monitor.setCursorPos(monitorWidth, y +2)
    monitor.write("#")
    
    monitor.setCursorPos(monitorWidth, monitorHeight)
    monitor.write("v")

    return
end

local function draw()
    while running do
        clear()
        writeList(list, scroll)
        writeScroll()
        sleep()
    end
    
    return
end

local function quit()
    running = false
    saveList()
    error()
    return
end

local function addList(todo)
    table.insert(list, todo)
    
    return
end

local function scrollList(y)
    if scroll +y >= 0 and scroll +y < #list - (monitorHeight -1) then
        scroll = scroll +y
    end
    
    return
end

local function select(value)
    if not value or value < 0 or value > #list then
        selected = nil
        return
    end

    selected = value
    return
end

local function checkInput()
    while running do
        local event, key, x, y = os.pullEvent()
        
        if event == "monitor_touch" then
            if x == monitorWidth then
                if y == monitorHeight then
                    scrollList(1)
                elseif y == 1 then
                    scrollList(-1)
                end
            else
                select(y + scroll)
            end
        elseif event == "key_up" then
            if key == keys.q then
                quit()
            end
        elseif event == "terminate" then
            quit()
            break
        elseif event == "monitor_resize" then
            monitorWidth, monitorHeight = monitor.getSize()
        end
    end
    
    return
end

local function listenNet()
    modem = peripheral.find("modem", rednet.open)
    
    while running and rednet.isOpen() do
        local id, message = rednet.receive()
        if message then
            addList(message)
            saveList()
        end
    end
    
    rednet.close()
    return
end

list = readList()
parallel.waitForAll(draw, checkInput, listenNet)
quit()