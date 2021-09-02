term.write("Do you want to install todoroki client (y/n)? ")
local input = read()

if string.lower(input) ~= "y" then
    print("Canceling installation")
    error()
end

print("Installing todoroki server...")
shell.run("wget https://raw.githubusercontent.com/Daxanius/todoroki/develop/client/todoroki_client.lua")

print("Intallation finished")