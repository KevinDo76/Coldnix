local module = {}
    module.id=9
    module.name="cd"
    module.description='cd <path>\nchange the current working directory'
    module.func = function (rawText) 
        local function changedir(path)
            if WORKINGDRIVEPROXY.isDirectory(path) then
                _G.currentWorkingDir = path
                terminal.prefix = ((string.sub(WORKINGDRIVEADDRESS,1,4) == string.sub(BOOTDRIVEADDRESS,1,4) and "boot") or string.sub(WORKINGDRIVEADDRESS,1,4))..":"..currentWorkingDir..": "
                terminal.reload()
            else
                print(path..": is not a directory")
            end
        end

        local args = System.utility.getArgs(rawText)
        if args[2]~=nil then
            local path = System.utility.resolveFilePath(args[2])
            if WORKINGDRIVEPROXY.exists(path) then
                changedir(path)
            elseif string.find(path,":") then
                local chunks = string.split(path,":")
                chunks[1]=(string.sub(chunks[1],2,#chunks[1]) == "boot" and string.sub(BOOTDRIVEADDRESS,1,4) or string.sub(chunks[1],2,#chunks[1]))
                if #chunks[1]==4 and System.utility.resolveFullDriveAddress(chunks[1]) then
                    WORKINGDRIVEADDRESS = System.utility.resolveFullDriveAddress(chunks[1])
                    WORKINGDRIVEPROXY = component.proxy(System.utility.resolveFullDriveAddress(chunks[1]))
                    changedir((chunks[2] or "").."/" or "")
                else
                    print('"'..((chunks[1] == "" and "none") or chunks[1])..'" is not a valid drive address')
                end
            else
                print(System.utility.getPrefixWorkingDir()..path..": no such directory")
            end
        else
            print(module.descriptionls)
        end
    end
return module