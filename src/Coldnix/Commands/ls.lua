local module = {}
    module.id=8
    module.name="ls"
    module.description='List out all files/directories at <path> or the current directory'
    module.func = function (rawText) 
        local args = System.utility.getArgs(rawText)
        local driveAddress,filepath,driveSearchSucc,drivelookup = System.filesystem.resolveDriveLookup(args[2] or System.filesystem.getPrefixWorkingDir(WORKINGDRIVEADDRESS)..currentWorkingDir)
        filepath=System.filesystem.sanitizePath(filepath)
        local workingdrive = BOOTDRIVEADDRESS
        if driveSearchSucc or not drivelookup then
            workingdrive = component.proxy(driveAddress)
            filepath = (filepath:sub(1,1)~="/" and "/"..filepath) or filepath
            if workingdrive.exists(filepath) then
                if workingdrive.isDirectory(filepath) then
                    print("Directory <"..System.filesystem.getPrefixWorkingDir(driveAddress)..filepath..">:")
                    local filelist=workingdrive.list(filepath)
                    if #filelist==0 then print("No file") end
                    local longest = 0

                    for i,v in ipairs(filelist) do
                        if #v>longest then longest=#v end
                    end
                    for i,v in ipairs(filelist) do
                        if workingdrive.isDirectory(filepath.."/"..v) then
                            print(System.utility.padText("DIR   "..string.sub(v,1,#v-1),longest+8))
                        else
                            print(System.utility.padText("FILE  "..v,longest+8)..System.utility.floatCut(workingdrive.size(filepath..((filepath:sub(#filepath,#filepath)~="/" and "/") or "")..v)/1024,2).."KB")
                        end
                    end
                    
                else
                    print(System.filesystem.getPrefixWorkingDir(driveAddress or "")..filepath..": Is not a directory")
                end
            else
                print(System.filesystem.getPrefixWorkingDir(driveAddress or "")..filepath..": No such directory")
            end
        else
            print(System.filesystem.getPrefixWorkingDir(driveAddress or "").."/: No such drive")
        end
    end
return module