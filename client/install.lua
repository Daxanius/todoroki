term.write("Do you want to install Todoroki client (y/n)? ")
local input = read()

if string.lower(input) ~= "y" then
    print("Canceling installation")
    error()
end

print("Installing ")

print("Installing Todoroki client...")
shell.run("wget https://raw.githubusercontent.com/Daxanius/todoroki/develop/client/todoroki_client.lua")

settings.define("todoroki_client.serverid")

print("Intallation finished")