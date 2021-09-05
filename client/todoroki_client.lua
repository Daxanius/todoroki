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
    term.clear()

    return
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

local serverID = settings.get("todoroki_client.serverid")
if not serverID then
    term.write("Server ID: ")
    local value = read()
    set("todoroki_client.serverid", value)
end