local module = {}
    module.id=7
    module.name="edit"
    module.description="Simple text editor\nedit <path>"
    module.func = function (rawText)
        local args=System.utility.getArgs(rawText)
        if args[2] then
            if BOOTDRIVEPROXY.exists(args[2]) then
                if not BOOTDRIVEPROXY.isDirectory(args[2]) then
                    _G.editorFilePath=args[2]
                    local func=loadfile("/Coldnix/OSPrograms/textEditor.lua")
                    if func then
                        func()
                    end
                    func=nil
                else
                    print('"'..args[2]..'" is a directory')
                end
            else
                print('Unable to find file "'..args[2]..'"')
            end
        else
            print(module.description)
        end
    end
return module