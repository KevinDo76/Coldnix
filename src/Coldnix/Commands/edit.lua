local module = {}
    module.id=7
    module.name="edit"
    module.description="Simple text editor\nedit <path>"
    module.func = function (rawText)
        local args=System.utility.getArgs(rawText)
        if args[2] then
            _G.editorFilePath=System.utility.resolveFilePath(args[2])
            if BOOTDRIVEPROXY.exists(_G.editorFilePath) then
                if not BOOTDRIVEPROXY.isDirectory(_G.editorFilePath) then
                    local func=loadfile("/Coldnix/OSPrograms/textEditor.lua")
                    if func then
                        func()
                    end
                    func=nil
                else
                    print('"'.._G.editorFilePath..'" is a directory')
                end
            else
                print('Unable to find file "'.._G.editorFilePath..'"')
            end
        else
            print(module.description)
        end
    end
return module