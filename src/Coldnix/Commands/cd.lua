local module = {}
    module.id=9
    module.name="cd"
    module.description='cd <path>\nchange the current working directory.'
    module.func = function (rawText) 
        local function changedir(path)
            if WORKINGDRIVEPROXY.isDirectory(path) then
                _G.currentWorkingDir = path
                terminal.prefix = ((System.filesystem.getShortDriveName(WORKINGDRIVEADDRESS) == System.filesystem.getShortDriveName(BOOTDRIVEADDRESS) and "boot") or System.filesystem.getShortDriveName(WORKINGDRIVEADDRESS))..":"..currentWorkingDir..": "
                terminal.reload()
            else
                print(System.filesystem.getPrefixWorkingDir()..path..": Is not a directory")
            end
        end

        local args = System.utility.getArgs(rawText)
        if args[2]~=nil then
            local path = System.filesystem.resolveFilePath(args[2])
            if WORKINGDRIVEPROXY.exists(path) then
                changedir(path)
            elseif string.find(path,":") then
                local driveAdd,filepath,succ = System.filesystem.resolveDriveLookup(args[2])
                if succ then
                    WORKINGDRIVEADDRESS = System.filesystem.resolveFullDriveAddress(driveAdd)
                    WORKINGDRIVEPROXY = component.proxy(WORKINGDRIVEADDRESS)
                    changedir((#filepath==0 and filepath:sub(#filepath,#filepath)~="/" and filepath.."/") or filepath)
                else
                    print('<'..((driveAdd == "" and "none") or driveAdd)..':/> is not a valid drive address')
                end
            else
                print(System.filesystem.getPrefixWorkingDir()..path..": No such directory")
            end
        else
            print(module.description)
        end
    end
return module