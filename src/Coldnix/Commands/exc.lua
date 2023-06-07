local module = {}
    module.id=3
    module.name="exc"
    module.description='execute an executable at <path>'
    module.func = function (rawText)
        local args=System.utility.getArgs(rawText)
        if args[2]~=nil and args[2]~="" then
            local driveAddress,filePath,validdrive,drivelookup = System.filesystem.resolveDriveLookup(args[2])
            filePath = System.filesystem.sanitizePath(filePath)
            local drive=component.proxy(driveAddress)
            if (validdrive or not drivelookup) and drive.exists(filePath) and not drive.isDirectory(filePath) then
                local buffer = System.readfile(filePath,drive)
                local succ,err=pcall(function() 
                    local func,err=load(buffer,"="..args[2],"t",_G)
                    if func==nil then
                        print("An unhandled error had occured: "..err)
                    else
                        func()
                    end
                end)
                if not succ then
                    print("An unhandled error had occured: "..err)
                else
                    print('Executed "'..System.filesystem.getPrefixWorkingDir(driveAddress)..filePath..'"')
                end
            else
                if validdrive and drive.isDirectory(args[2]) then
                    print('"'..args[2]..'" is a directory')
                else
                    print('Unable to find an executable at "'..System.filesystem.getPrefixWorkingDir(driveAddress)..filePath..'"')
                end
            end
        else
            print(module.description)
        end
    end
return module