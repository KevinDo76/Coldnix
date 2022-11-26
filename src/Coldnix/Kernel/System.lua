--this will init system operation like saving a file, etc
_G.System = {}
System.utility = {}
System.writefile=function (path,data)
    if not BOOTDRIVEPROXY.isReadOnly() then
        local file=BOOTDRIVEPROXY.open(path,"w")
        return BOOTDRIVEPROXY.write(file,data)
    else
        print("System File Operation Error, Drive is read only")
    end
end

System.readfile= function(path,driveproxy)
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

System.utility.resolveFullDriveAddress = function(drivename)
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

System.utility.padText = function (txt,length)
    while (#txt<length) do
        txt=txt.." "
    end
    return txt
end

System.utility.getPrefixWorkingDir = function()
    return ((string.sub(WORKINGDRIVEADDRESS,1,4) == string.sub(BOOTDRIVEADDRESS,1,4) and "boot") or string.sub(WORKINGDRIVEADDRESS,1,4))..":"
end

System.utility.sanitizePath = function (path) 
    while (string.sub(path,#path,#path)=="/" and #path>1) do path=string.sub(path,1,#path-1) end
    while (string.find(path,"//")~=nil) do path=string.gsub(path,"//","/") end
    local pathComp=string.split(path,"/")
    local drive = WORKINGDRIVEPROXY
    local includeDriveChange = false
    local driveAddress = WORKINGDRIVEADDRESS
    local validAddress=true
    local reconstruct="/"
    pathComp[1] = pathComp[1] or ""
    if pathComp[1]:find(":") then
        includeDriveChange = true
        pathComp[1] = string.sub(pathComp[1],1,#pathComp[1]-1)
        pathComp[1] = (pathComp[1] == "boot" and string.sub(BOOTDRIVEADDRESS,1,4) or pathComp[1])
        driveAddress = System.utility.resolveFullDriveAddress(pathComp[1])
        if driveAddress then
            drive = component.proxy(driveAddress)
        else
            validAddress=false
        end
    end

    for i=(includeDriveChange and 2) or 1,#pathComp do
        if drive.exists(reconstruct..((pathComp[i]:sub(1,1)~="/" and "/") or "")..pathComp[i]) then
            for j,k in ipairs(drive.list(reconstruct)) do
                if string.sub(k:lower(),1,#k-1) == pathComp[i]:lower() then
                    reconstruct=reconstruct..((reconstruct:sub(#reconstruct,#reconstruct)~="/" and "/") or "")..string.sub(k,1,#k-1)
                end
            end
        else
            validAddress=false
            break
        end
    end
    if validAddress then path="" end
    if includeDriveChange and validAddress then path="/"..driveAddress:sub(1,4)..":" end
    if validAddress then path=path..((reconstruct=="/" and includeDriveChange and "") or reconstruct) end
    return path
end

System.utility.resolveFilePath = function(path)
    if string.find(path,":") then path = "/"..path end
    if string.sub(path,1,1)=="/" then
        return System.utility.sanitizePath(path)
    else
        if (currentWorkingDir~="/") then
            return System.utility.sanitizePath(currentWorkingDir.."/"..path)
        else
            return System.utility.sanitizePath(currentWorkingDir..path)
        end
    end
end

System.utility.containPeriod = function(text) 
    for i=1,#text do
        if string.sub(text,i,i) == "." then
            return false
        end
    end
    return false
end

System.utility.floatCut = function (num,fdc)
    fdc=fdc or 1
    return math.floor(num*(10^fdc))/(10^fdc)
end
--more advance version of string.split, this can handle text in "" for aurgments with spaces
System.utility.getArgs = function (txt)
    local dataChunk={}
    local tempChunk=""
    local inQuote=false
    local rDex=1
    while (rDex<=#txt) do
        if string.sub(txt,rDex,rDex)=='"' then
            inQuote=not inQuote
            if not inQuote then
                dataChunk[#dataChunk+1] = tempChunk
                tempChunk=""
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