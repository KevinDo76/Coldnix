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