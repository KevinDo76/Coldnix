local module = {}
    module.name="help"
    module.description='list out all avaliables commands\n"help <command_name>" to display descriptions'
    module.func = function (rawText)
        local args=string.split(rawText," ")
        if #args==1 then
            print('"help <command_name>" for further information')
            print("/avaliable commands list")
            local count=1
            for i,v in pairs(commandAPI.validCommands) do
                print("  "..count..". "..i)
                count=count+1
            end
        else 
            if commandAPI.validCommands[args[2]]~=nil then
                print('/'..args[2].." description")
                print(commandAPI.validCommands[args[2]][2])
            else
                print('Unknown command "'..args[2]..'"')
            end
        end
    end
return module