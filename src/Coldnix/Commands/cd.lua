local module = {}
    module.id=9
    module.name="cd"
    module.description='cd <path>\nchange the current working directory.'
    module.func = function (rawText) 
        local function changedir(path)
            if WORKINGDRIVEPROXY.isDirectory(path) then
                _G.currentWorkingDir = path
                terminal.prefix = ((string.sub(WORKINGDRIVEADDRESS,1,4) == string.sub(BOOTDRIVEADDRESS,1,4) and "boot") or string.sub(WORKINGDRIVEADDRESS,1,4))..":"..currentWorkingDir..": "
                terminal.reload()
            else
                print(System.utility.getPrefixWorkingDir()..path..": Is not a directory")
            end
        end

        local args = System.utility.getArgs(rawText)
        if args[2]~=nil then
            local path = System.utility.resolveFilePath(args[2])
            if WORKINGDRIVEPROXY.exists(path) then
                changedir(path)
            elseif string.find(path,":") then
                local driveAdd,filepath,succ = System.utility.resolveDriveLookup(args[2])
                if succ then
                    WORKINGDRIVEADDRESS = System.utility.resolveFullDriveAddress(driveAdd)
                    WORKINGDRIVEPROXY = component.proxy(System.utility.resolveFullDriveAddress(driveAdd))
                    changedir((filepath or "").."/" or "")
                else
                    print('<'..((driveAdd == "" and "none") or driveAdd)..':/> is not a valid drive address')
                end
            else
                print(System.utility.getPrefixWorkingDir()..path..": No such directory")
            end
        else
            print(module.description)
        end
    end
return module