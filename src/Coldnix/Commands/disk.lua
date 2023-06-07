local module = {}
    module.id=7
    module.name="disk"
    module.description='Disk utility command\n  <list> Display all detectable disks'
    module.func = function (rawText)
        local args = System.utility.getArgs(rawText)
        if args[2]~=nil then
            if args[2]:lower()=="list" then
                local complist = component.list()
                local count=1
                for i,v in pairs(complist) do
                    if v=="filesystem" then
                        local proxy = component.proxy(i)
                        print(count..") "..((i:sub(1,driveAddressLength)==System.filesystem.getShortDriveName() and "boot") or i:sub(1,driveAddressLength))..":/  "..i:sub(1,8).."  "..System.utility.floatCut(proxy.spaceUsed()/1024,2).."KB / "..System.utility.floatCut(proxy.spaceTotal()/1024,2).."KB  "..((proxy.isReadOnly() and "Read") or "Read/Write"))
                        count=count+1
                    end
                end
            end
        else
            print(module.description)
        end
    end
return module