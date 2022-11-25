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

System.readfile= function(path)
    if BOOTDRIVEPROXY.exists(path) and not BOOTDRIVEPROXY.isDirectory(path) then
        local file=BOOTDRIVEPROXY.open(path)
        local finalEx=""
        repeat 
            local currentLoad=BOOTDRIVEPROXY.read(file,math.huge)
            finalEx=finalEx..(currentLoad or "")
        until not currentLoad
        return finalEx,true
    else
        return "",false
    end
end

System.utility.getCorrectCapName = function(path,file)

end

System.utility.padText = function (txt,length)
    while (#txt<length) do
        txt=txt.." "
    end
    return txt
end

System.utility.sanitizePath = function (path) 
    while (string.sub(path,#path,#path)=="/" and #path>1) do path=string.sub(path,1,#path-1) end
    while (string.find(path,"//")~=nil) do path=string.gsub(path,"//","/") end
    return path
end

System.utility.resolveFilePath = function(path)
    if string.sub(path,1,1)=="/" then
        return System.utility.sanitizePath(path)
    else
        if (terminal.currentWorkingDir~="/") then
            return System.utility.sanitizePath(terminal.currentWorkingDir.."/"..path)
        else
            return System.utility.sanitizePath(terminal.currentWorkingDir..path)
        end
    end
end

System.utility.containPeriod = function(text) 
    for i=1,#text do
        if string.sub(text,i,i) == "." then
            return true
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