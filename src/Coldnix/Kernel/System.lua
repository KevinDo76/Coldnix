--this will init system operation like saving a file, etc
_G.System = {}
--------------SYSTEM UTILITY--------------
System.utility = {}
System.filesystem = {}
System.writefile=function (path,data,drive)
    drive = drive or BOOTDRIVEPROXY
    if not drive.isReadOnly() then
        local file=drive.open(path,"w")
        return drive.write(file,data)
    else
        print("System file operation error, drive is read only")
        return false
    end
end

System.readfile = function(path,driveproxy)
    driveproxy=driveproxy or BOOTDRIVEPROXY
    if driveproxy.exists(path) and not driveproxy.isDirectory(path) then
        local file=driveproxy.open(path)
        local finalEx=""
        repeat 
            local currentLoad=driveproxy.read(file,math.huge)
            finalEx=finalEx..(currentLoad or "")
        until not currentLoad
        return finalEx,true
    else
        return "",false
    end
end

--just incase special treatment is needed
System.listDirectory = function(path,driveproxy)
    driveproxy=driveproxy or BOOTDRIVEPROXY
    if driveproxy.exists(path) and driveproxy.isDirectory(path) then
        return driveproxy.list(path)
    end
    return false
end

System.utility.padText = function (txt,length)
    while (#txt<length) do
        txt=txt.." "
    end
    return txt
end

System.utility.floatCut = function (num,fdc)
    fdc=fdc or 1
    return math.floor(num*(10^fdc))/(10^fdc)
end
--more advance version of string.split, this can handle text in "" for aurgments with spaces
System.utility.getArgs = function (txt)
    txt=txt or ""
    --remove spaces at the end
    while (txt:sub(#txt,#txt)==" ") do txt = txt:sub(1,#txt-1) end
    local dataChunk={}
    local tempChunk=""
    local inQuote=false
    local rDex=1
    while (rDex<=#txt) do
        if string.sub(txt,rDex,rDex)=='"' then
            inQuote=not inQuote
            if not inQuote then
                --possibly unnecessary
                --dataChunk[#dataChunk+1] = tempChunk
                --tempChunk=""
            end
        elseif string.sub(txt,rDex,rDex)==" " then
            if not inQuote then
                if tempChunk~="" then
                    dataChunk[#dataChunk+1] = tempChunk
                    tempChunk=""
                end
            else
                tempChunk=tempChunk.." "
            end
        elseif string.sub(txt,rDex,rDex)~=" " then
            tempChunk=tempChunk..string.sub(txt,rDex,rDex)
        end
        rDex=rDex+1
    end
    if not inQuote then
        dataChunk[#dataChunk+1] = tempChunk
    end
    return dataChunk
end


--------------FILE SYSTEM--------------
_G.driveAddressLength=tonumber(config.configList.OSDRIVENAMELENGTH)

System.filesystem.getShortDriveName = function(drive)
    drive = drive or WORKINGDRIVEADDRESS
    return string.sub(drive,1,driveAddressLength)
end

System.filesystem.getPrefixWorkingDir = function(driveAddress)
    driveAddress=driveAddress or WORKINGDRIVEADDRESS
    return ((System.filesystem.getShortDriveName(driveAddress) == System.filesystem.getShortDriveName(BOOTDRIVEADDRESS) and "boot") or System.filesystem.getShortDriveName(driveAddress))..":"
end

System.filesystem.resolveFullDriveAddress = function(drivename)
    local attached=component.list()
    local found=false
    local foundAddress
    for i,v in pairs(attached) do
        if v=="filesystem" then
            if string.sub(i,1,#drivename)==drivename then
                if not found then
                    found=true
                    foundAddress=i
                else
                    foundAddress=nil
                    break
                end
            end
        end
    end
    return foundAddress or false
end

System.filesystem.sanitizePath = function (path) 
    while (string.sub(path,#path,#path)=="/" and #path>1) do path=string.sub(path,1,#path-1) end
    while (string.find(path,"//")~=nil) do path=string.gsub(path,"//","/") end
    local pathComp=string.split(path,"/")
    local drive = WORKINGDRIVEPROXY
    local includeDriveChange = false
    local driveAddress = WORKINGDRIVEADDRESS
    local validAddress=true
    local reconstruct="/"
    local tempPathComp = {}
    --move to parent directory implentation
    for i,v in ipairs(pathComp) do
        if v == ".." then
            tempPathComp[#tempPathComp ] = nil
        else
            tempPathComp[#tempPathComp + 1] = v
        end
    end

    pathComp = tempPathComp
    pathComp[1] = pathComp[1] or ""
    if pathComp[1]:find(":") then
        includeDriveChange = true
        pathComp[1] = string.sub(pathComp[1],1,#pathComp[1]-1)
        pathComp[1] = (pathComp[1] == "boot" and string.sub(BOOTDRIVEADDRESS,1,driveAddressLength) or pathComp[1])
        driveAddress = System.filesystem.resolveFullDriveAddress(pathComp[1])
        if driveAddress then
            drive = component.proxy(driveAddress)
        else
            validAddress=false
        end
    end

    for i=(includeDriveChange and 2) or 1,#pathComp do
        if drive.exists(reconstruct..((pathComp[i]:sub(1,1)~="/" and "/") or "")..pathComp[i]) then
            for j,k in ipairs(drive.list(reconstruct)) do
                if ((k:sub(#k,#k)=="/" and k:sub(1,#k-1)) or k):lower() == pathComp[i]:lower() then
                    reconstruct=reconstruct..((reconstruct:sub(#reconstruct,#reconstruct)~="/" and "/") or "")..((k:sub(#k,#k)=="/" and k:sub(1,#k-1)) or k)
                end
            end
        else
            validAddress=false
            break
        end
    end
    
    if validAddress then path="" end
    if includeDriveChange and validAddress then path="/"..string.sub(driveAddress or "",1,driveAddressLength)..":" end
    if validAddress then path=path..((reconstruct=="/" and includeDriveChange and "") or reconstruct) end

    return path
end

--return driveaddress, filepath without drive address, validdrive, drive lookup
System.filesystem.resolveDriveLookup = function (rawinput)
    if rawinput:find(":") then
        local split=string.split(rawinput,":")
        split[2] = ((split[2] or ""):sub(1,1)~="/" and "/"..(split[2] or "")) or split[2]
        split[1]=split[1]..":"
        rawinput = table.concat(split)
    end
    local path = System.filesystem.resolveFilePath(rawinput)
    if path:find(":") then
        rawinput = (rawinput:sub(1,1)~="/" and "/"..rawinput) or rawinput
        local chunks = string.split(rawinput,":")
        local processedChunks = string.split(path,":")
        chunks[1]=(string.sub(chunks[1],2,#chunks[1]) == "boot" and string.sub(BOOTDRIVEADDRESS,1,driveAddressLength) or string.sub(chunks[1],2,#chunks[1]))
        if #chunks[1]==driveAddressLength and System.filesystem.resolveFullDriveAddress(chunks[1]) then
            return System.filesystem.resolveFullDriveAddress(chunks[1]) or "",processedChunks[2] or "",true,true 
        else
            return chunks[1] or "",processedChunks[2] or "",false,true
        end 
    else
        return WORKINGDRIVEADDRESS, path, false, false
    end
end

System.filesystem.resolveFilePath = function(path)
    if string.find(path,":") then path = "/"..path end
    if string.sub(path,1,1)=="/" then
        return System.filesystem.sanitizePath(path)
    else
        if (currentWorkingDir~="/") then
            return System.filesystem.sanitizePath(currentWorkingDir.."/"..path)
        else
            return System.filesystem.sanitizePath(currentWorkingDir..path)
        end
    end
end