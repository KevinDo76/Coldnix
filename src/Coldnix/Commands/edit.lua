local module = {}
    module.id=7
    module.name="edit"
    module.description="Simple text editor\nedit <path>"
    module.func = function (rawText)
        local args=System.utility.getArgs(rawText)
        if args[2] then
            local driveaddress,editorFilePath,drivevalid,drivelookup=System.utility.resolveDriveLookup(args[2])
            local drive=component.proxy(driveaddress)
            if (drivevalid or not drivelookup) and drive.exists(editorFilePath) then
                if not drive.isDirectory(editorFilePath) then
                    local func=loadfile("/Coldnix/OSPrograms/textEditor.lua")
                    if func then
                        func(driveaddress,editorFilePath)
                    end
                    func=nil
                else
                    print('"'..System.utility.getPrefixWorkingDir(driveaddress)..editorFilePath..'" is a directory')
                end
            else
                print('Unable to find "'..System.utility.getPrefixWorkingDir(driveaddress)..editorFilePath..'"')
            end
        else
            print(module.description)
        end
    end
return module