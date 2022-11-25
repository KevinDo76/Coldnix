local module = {}
    module.id=8
    module.name="ls"
    module.description='list out all files/directories at <path> or the current directory'
    module.func = function (rawText) 
        local args = System.utility.getArgs(rawText)
        local path = System.utility.resolveFilePath(args[2] or "")
        if BOOTDRIVEPROXY.exists(path) then
            if BOOTDRIVEPROXY.isDirectory(path) then
                print("Directory <"..path..">:")
                for i,v in ipairs(BOOTDRIVEPROXY.list(path)) do
                    if BOOTDRIVEPROXY.isDirectory(path.."/"..v) then
                        print("DIR   "..string.sub(v,1,#v-1))
                    else
                        print("FILE  "..v)
                    end
                end
            else
                print(path..": is not a directory")
            end
        else
            print(path..": no such directory")
        end
    end
return module