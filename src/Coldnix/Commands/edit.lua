local module = {}
    module.id=7
    module.name="edit"
    module.description="Simple text editor\nedit <path>"
    module.func = function (rawText)
        local args=System.utility.getArgs(rawText)
        if args[2] then
            local editorFilePath=System.utility.resolveFilePath(args[2])
            if WORKINGDRIVEPROXY.exists(editorFilePath) then
                if not WORKINGDRIVEPROXY.isDirectory(editorFilePath) then
                    local func=loadfile("/Coldnix/OSPrograms/textEditor.lua")
                    if func then
                        func(editorFilePath)
                    end
                    func=nil
                else
                    print('"'..System.utility.getPrefixWorkingDir()..editorFilePath..'" is a directory')
                end
            else
                print('Unable to find file "'..System.utility.getPrefixWorkingDir()..editorFilePath..'"')
            end
        else
            print(module.description)
        end
    end
return module