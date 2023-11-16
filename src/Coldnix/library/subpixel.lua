local module = {}
module.name = "subpixel"
module.getSubpixelCharacterFromString = function(data) 
    local baseHexValue = 0x2800
    local brallieIndexToHexMap = {0x1,0x8,0x2,0x10,0x4,0x20,0x40,0x80}
    if (#data==8) then
        local offsetTotal = 0
        for i=1,8 do
            if data:sub(i,i) == "1" then
                offsetTotal=offsetTotal+brallieIndexToHexMap[i]
            end
        end
        offsetTotal=offsetTotal+baseHexValue
        return utf8.char(offsetTotal)
    end
    return false
end

module.renderSubPixelImageFromString = function (data, posX, posY)
    local hex2bin = {["0"] = "0000",["1"] = "0001",["2"] = "0010",["3"] = "0011",["4"] = "0100",["5"] = "0101",["6"] = "0110",["7"] = "0111",["8"] = "1000",["9"] = "1001",["a"] = "1010",["b"] = "1011",["c"] = "1100",["d"] = "1101",["e"] = "1110",["f"] = "1111"}
    local gpu = BOOTGPUPROXY
    local RowData = string.split(data,"\n")
    local palette = {}
    for i = 0,#RowData[1]/6 do
        palette[#palette+1] = RowData[1]:sub(i*6+1,(i+1)*6)
    end
    local rx,ry = gpu.getResolution()
    --gpu.fill(1,1,rx,ry," ")
    for i = 2,#RowData do
        if (#RowData[i] == 5) then
            gpu.setForeground(tonumber(palette[tonumber(RowData[i]:sub(1,2),16)],16))
            gpu.setBackground(tonumber(palette[tonumber(RowData[i]:sub(3,4),16)],16))
        else
            for x = 1,#RowData[i]/6 do
                local subpixelConfig = RowData[i]:sub((x-1)*6+1,(x-1)*6+2)
                local px = tonumber(RowData[i]:sub((x-1)*6+3,(x-1)*6+4),16)
                local py = tonumber(RowData[i]:sub((x-1)*6+5,(x-1)*6+6),16)

                subpixelConfig = hex2bin[string.sub(subpixelConfig,2,2)]:reverse()..hex2bin[string.sub(subpixelConfig,1,1)]:reverse()
                gpu.set(px+posX-1,py+posY-1,module.getSubpixelCharacterFromString(subpixelConfig))
            end
        end
    end
end

module.renderSubPixelImageFromDisk = function(path, posX, posY)
    local hex2bin = {["0"] = "0000",["1"] = "0001",["2"] = "0010",["3"] = "0011",["4"] = "0100",["5"] = "0101",["6"] = "0110",["7"] = "0111",["8"] = "1000",["9"] = "1001",["a"] = "1010",["b"] = "1011",["c"] = "1100",["d"] = "1101",["e"] = "1110",["f"] = "1111"}
    local gpu = BOOTGPUPROXY
    local driveAddress,filepath,driveSearchSucc,drivelookup = System.filesystem.resolveDriveLookup(path)
    --terminal.stopProcess()
    if driveSearchSucc or not drivelookup then
        local data,readsucc = System.readfile(filepath,component.proxy(driveAddress))  
        if readsucc then
            module.renderSubPixelImageFromString(data, posX, posY)
        end
    end
end
return module