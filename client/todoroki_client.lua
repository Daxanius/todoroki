error("Todoroki is still in development")
print("Checking peripherals")

local modem = peripheral.find("modem")
if not modem then
    error("No modem found")
end

print("Peripherals OK")
print("Starting Todoroki")

local screenWidth, screenHeight = term.getSize()

local running = true

local function clear()
    term.setBackgroundColor(colors.black)
    
    term.clear()
    term.setCursorPos(1,1)

    return
end

local function quit()
    print("Quitting Todoroki")

    running = false
    rednet.close()
    clear()

    return
end

local function handShake(id)
    print("Checking connection")
    modem = peripheral.find("modem", rednet.open)

    print("Pinging server")
    rednet.send(id, "ping")

    print("Awaiting response")
    local response_id, response = rednet.receive()

    if response ~= "pong" or response_id ~= id then
        print("Connection failed")
        rednet.close()
        return false
    end

    print("Connection verified")
    rednet.close()
    return true
end

local function send(id, todo, --[[optional]]type)
    type = type or 0

    local prefix = ""
    if type == 0 then
        prefix = "TODO: "
    elseif type == 1 then
        prefix = "DONE: "
    elseif type == 2 then
        prefix = "IDEA "
    end

    modem = peripheral.find("modem", rednet.open)

    rednet.send(id, prefix .. todo)

    rednet.close()
    return
end

local function drawBackground()
    paintutils.drawFilledBox(1, 1, screenWidth, screenHeight, colors.blue)
end

local function drawPrompt()
    paintutils.drawFilledBox(screenHeight / 2, screenWidth / 2 - 10, screenHeight / 2, screenWidth / 2)
end

local function draw()
    while running do
        clear()
        drawBackground()
        drawPrompt()
        sleep()
    end
end

local serverID = settings.get("todoroki_client.serverid")
if not serverID then
    term.write("Server ID: ")
    local serverID = read()
    settings.set("todoroki_client.serverid", serverID)
end

if not handShake(tonumber(serverID)) then
    quit()
end

print("Todoroki started")
draw()