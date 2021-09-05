term.write("Do you want to install Todoroki server (y/n)? ")
local input = read()

if string.lower(input) ~= "y" then
    print("Canceling installation")
    error()
end

print("Installing Todoroki server...")
shell.run("wget https://raw.githubusercontent.com/Daxanius/todoroki/develop/server/todoroki_server.lua")

print("Intallation finished")