local module = {}
    module.id=8
    module.name="ls"
    module.description='List out all files/directories at <path> or the current directory'
    module.func = function (rawText) 
        local args = System.utility.getArgs(rawText)
        local path = System.utility.resolveFilePath(args[2] or "")
        local driveAddress,filepath,succ,drivelookup = System.utility.resolveDriveLookup(args[2] or "")
        filepath=System.utility.sanitizePath(filepath)
        local workingdrive = BOOTDRIVEADDRESS
        if succ or not drivelookup then
            workingdrive = component.proxy(driveAddress)
            --print(succ,filepath or "nil",path or "nil", driveAddress or "nil", workingdrive)
            filepath = (filepath:sub(1,1)~="/" and "/"..filepath) or filepath
            if workingdrive.exists(filepath) then
                if workingdrive.isDirectory(filepath) then
                    print("Directory <"..System.utility.getPrefixWorkingDir(driveAddress)..filepath..">:")
                    local filelist=workingdrive.list(filepath)
                    if #filelist==0 then print("No file") end
                    for i,v in ipairs(filelist) do
                        if workingdrive.isDirectory(filepath.."/"..v) then
                            print("DIR   "..string.sub(v,1,#v-1))
                        else
                            print("FILE  "..v)
                        end
                    end
                else
                    print(System.utility.getPrefixWorkingDir(driveAddress or "")..filepath..": Is not a directory")
                end
            else
                print(System.utility.getPrefixWorkingDir(driveAddress or "")..filepath..": No such directory")
            end
        else
            print(System.utility.getPrefixWorkingDir(driveAddress or "").."/: No such drive")
        end
    end
return module