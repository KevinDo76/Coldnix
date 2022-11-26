local module = {}
    module.id=3
    module.name="exc"
    module.description='execute an executable at <path>'
    module.func = function (rawText)
        local args=System.utility.getArgs(rawText)
        local drive=WORKINGDRIVEPROXY
        if args[2]~=nil and args[2]~="" then
            args[2] = System.utility.resolveFilePath(args[2])
            if drive.exists(args[2]) and not drive.isDirectory(args[2]) then
                local file=drive.open(args[2])
                local buffer=""
                repeat
                    local data
                    data=drive.read(file,math.huge)
                    buffer=buffer..(data or "")
                until data==nil
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
                    print('Executed "'..System.utility.getPrefixWorkingDir()..args[2]..'"')
                end
            else
                if drive.isDirectory(args[2]) then
                    print('"'..args[2]..'" is a directory')
                else
                    print('Unable to find an executable at "'..System.utility.getPrefixWorkingDir()..args[2]..'"')
                end
            end
        else
            print(module.description)
        end
    end
return module