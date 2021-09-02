local monitor = peripheral.find("monitor")
if not monitor then
    error("No monitor found")
end

local modem = peripheral.find("modem")
if not modem then
    error("No modem found")
end

local monitorWidth, monitorHeight = monitor.getSize()
local termWidth, termHeight = term.getSize()

local running = true
local list = {}
local scroll = 0
local selected

local function quit(--[[optional]]message)
    message = message or nil

    running = false
    saveList()
    error(message)
    return
end

local function prompt(message, --[[optional]]color)
    color = color or colors.white
    term.write(message)
    local answer = read()

    if string.lower(answer) ~= "y" then
        return false
    end

    return true
end

local function clear()
    monitor.setBackgroundColor(colors.black)
    
    monitor.clear()
    monitor.setTextScale(0.5)
    monitor.setCursorPos(1,1)

    return
end

function readList()
    print("Retreiving list from file list.txt")

    local file = fs.open("list.txt","r")
    
    if not file then
        print("File not found, creating empty list")
        return {}
    end
    
    local data = file.readAll()
    
    file.close()
    
    if data == "" then
        print("File list.txt is empty, creatig empty list")
        return {}
    end

    local list = textutils.unserialise(data)

    if not list then
        if prompt("File list.txt is corrupt, overwrite file (y/n)? ", colors.yellow) then
            print("Creating empty list")
            return {}
        end

        error("Save data is corrupt")
    end
    
    print("List succesfully retreived from list.txt")
    return list
end

function saveList()
    print("Saving list to file list.txt")

    local file = fs.open("list.txt", "w")
    
    file.write(textutils.serialise(list))
    
    file.close()

    print("List saved succesfully")
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
    monitor.setBackgroundColor(colors.black)
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

local function listenCommand()
    while running do
        print("->")
        local x, y = term.getCursorPos()
        term.setCursorPos(3, y -1)
        local input = read()
    end

    return
end

local function listenNet()
    print("Starting server")
    modem = peripheral.find("modem", rednet.open)

    print("Server started")
    
    while running and rednet.isOpen() do
        local id, message = rednet.receive()
        if message then
            print("Received", message, "from client with id", id)
            addList(message)
            saveList()
        end
    end
    
    print("Stopping server")
    rednet.close()

    print("Server stopped")
    return
end

list = readList()
parallel.waitForAll(draw, checkInput, listenNet, listenCommand)
quit()