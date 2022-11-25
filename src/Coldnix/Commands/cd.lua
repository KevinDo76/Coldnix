local module = {}
    module.id=9
    module.name="cd"
    module.description='cd <path>\nchange the current working directory'
    module.func = function (rawText) 
        local args = System.utility.getArgs(rawText)
        if args[2]~=nil then
            local path = System.utility.resolveFilePath(args[2])
            if not System.utility.containPeriod(args[2]) then
                if BOOTDRIVEPROXY.exists(path) then
                    if BOOTDRIVEPROXY.isDirectory(path) then
                        terminal.currentWorkingDir = path
                        terminal.prefix = terminal.currentWorkingDir..": "
                        terminal.reload()
                    else
                        print(path..": is not a directory")
                    end
                else
                    print(path..": no such directory")
                end
            end
        else
            print(module.descriptionls)
        end
    end
return module