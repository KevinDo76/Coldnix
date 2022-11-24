local module = {}
    module.id=1
    module.name="help"
    module.description='list out all avaliables commands\n"help <command_name>" to display descriptions'
    module.func = function (rawText)
        local linePerPage=tonumber(config.configList.HELPCOMMANDPERPAGE)
        local args=string.split(rawText," ")
        if #args==1 or tonumber(args[2]) then
            local page=tonumber(args[2] or 1)
            local sortedList={}
            for i,v in pairs(commandAPI.validCommands) do
                sortedList[v[4]]=i
            end
            print('"help <command_name>" for further information')
            page=math.clamp(page,1,math.ceil(#sortedList/linePerPage))
            print("/avaliable commands list, page<"..page.."><1-"..math.ceil(#sortedList/linePerPage)..">")
            for i,v in ipairs(sortedList) do
                if (i)>((page-1)*linePerPage) and (i-1)<((page)*linePerPage) then
                    print("  "..i..". "..v)
                end
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