local module = {}
module.name = "videoEngine"

local getTableElementLength = function(t)
    local l=0
    for i=1,#t do
        l=l+t[i][2]
    end
    return l
end
local gsub = string.gsub
local stringsub=string.sub
local unpackText = function(txt,subTable)
    for i=1,#subTable do
        local v=subTable[i]
        local textTab = {}
        for charI = 1,#txt do
            local character = stringsub(txt,charI,charI)
            if character==v[1] then
                textTab[#textTab+1] = v[2]
            else
                textTab[#textTab+1] = character
            end
        end
        txt = table.concat(textTab,"") 
    end
    return txt
end

module.playVideo = function(path)
    local mapping = {
        ["9"]="FF",
        ["8"]="F0",
        ["7"]="D2",
        ["6"]="B4",
        ["5"]="96",
        ["4"]="78",
        ["3"]="5A",
        ["2"]="3C",
        ["1"]="1E",
        ["0"]="0"
    }
    local driveAddress,filepath,driveSearchSucc,drivelookup = System.filesystem.resolveDriveLookup(path)
    local pOffset = 0
    local maxP = 1
    local data=""
    if driveSearchSucc or not drivelookup then
        local file = System.getFileHandle(filepath,component.proxy(driveAddress)) 
        if file then
            local gpu=BOOTGPUPROXY
            local peakLag = 0
            local dataFetchRate = 500
            local frameCount
            local gpuset = BOOTGPUPROXY.set
            local gpubackground = BOOTGPUPROXY.setBackground
            local gpuforeground = BOOTGPUPROXY.setForeground
            local currentF = 0
            local tableinsert=table.insert
            local backbuffer = gpu.allocateBuffer(160,50)
            local currentFrame = {}
            local rawCurrent={}
            local lastFrame = nil
            local nextRun = {}
            local currentReadP = 0
            local inCompressBlock = false
            local blockLength = ""
            local currentFrameLengthCount = 0
            local dataBuffSize = 0
            local driveProxRead = component.proxy(driveAddress).read
            local uptime = computer.uptime
            local mathfloor = math.floor
            local subTable = {}


            new = driveProxRead(file,500)
            sections = string.split(new,"|") 
            frameCount = tonumber(sections[2])
            preIndexedSub = string.split(sections[1],"!")
            for i,v in ipairs(preIndexedSub) do
                local subIndex = string.split(v," ")
                subTable[#subTable+1] = {subIndex[1],subIndex[2]}
            end


            print(frameCount,"frames")

            data = sections[3]
            data = unpackText(data, subTable)
            maxP = maxP + #data
            dataBuffSize = #data

            

            for i=1,frameCount do
                tableinsert(nextRun,computer.uptime()+(i*0.1))
            end
            gpu.setActiveBuffer(backbuffer)
            while currentReadP<maxP do
                --read in more data then the buffer is low
                if (dataBuffSize<2) then
                    new = driveProxRead(file,dataFetchRate)
                    if new then
                        new = unpackText(new, subTable)
                        local tempT = {data,new}
                        data = table.concat(tempT)
                        maxP = maxP + #new 
                        dataBuffSize = #data
                    end
                end
                if computer.ElapseT>3.5 then
                    wait()
                end
                CheckYield()
                currentReadP=currentReadP+1

                --parsing video data stream, decompressing
                if stringsub(data,1,1) == "r" then
                    inCompressBlock = not inCompressBlock
                    if not inCompressBlock then
                        currentFrame[currentFrameLengthCount +1] = {stringsub(data,2,2) ,tonumber(blockLength)}
                        currentFrameLengthCount=currentFrameLengthCount+1
                        blockLength = ""
                        data=stringsub(data,2)
                        dataBuffSize=dataBuffSize-1
                        currentReadP=currentReadP+1
                    end
                elseif inCompressBlock then
                    blockLength = blockLength..stringsub(data,1,1) 
                elseif not inCompressBlock and blockLength=="" then
                    currentFrame[currentFrameLengthCount + 1] = {stringsub(data,1,1), 1}
                    currentFrameLengthCount=currentFrameLengthCount+1
                end

                --removing already read data
                data=stringsub(data,2)
                dataBuffSize=dataBuffSize-1


                --render a frame when enough data is collected, 8000 character is required for 160x50
                if getTableElementLength(currentFrame)>=8000 then
                    currentF=currentF+1
                    while uptime()<nextRun[currentF] or computer.ElapseT>3.5 do
                        wait()
                    end
                    if uptime()-nextRun[currentF]>peakLag then
                        peakLag = uptime()-nextRun[currentF]
                    end

                    if uptime()-nextRun[currentF]<1 or true then
                        if lastFrame == nil then
                            c=0
                            for i,v in ipairs(currentFrame) do 
                                gpu.setBackground(tonumber("0x"..mapping[v[1]]..mapping[v[1]]..mapping[v[1]]))

                                for _=1,v[2] do
                                    c=c+1
                                    local y = mathfloor(c/160)
                                    local x = c-(160*y)
                                    rawCurrent[#rawCurrent+1] = v[1]
                                    gpu.set(x,y," ")
                                end
                            end
                        else
                            for i=1,#currentFrame do 
                                for j=1,currentFrame[i][2] do
                                    rawCurrent[#rawCurrent+1]=currentFrame[i][1]
                                end
                            end

                            local lastColor = nil
                            local renderChunkStart=1
                            local lastY = 1
                            local textChunk = {}
                            local lastI = 1
                            local drawCache = {}
                            gpubackground(0x000000)

                            for i=1,160*50 do
                                processed = false
                                c = rawCurrent[i]
                                local y = mathfloor(i/160)
                                if rawCurrent[i]~=lastFrame[i] then
                                    local idiff = i - lastI
                                    local ydiff = y - lastY
                                    if lastColor~=c then
                                        if not lastColor then lastColor = c end
                                        if not drawCache["0x"..mapping[lastColor]..mapping[lastColor]..mapping[lastColor]] then drawCache["0x"..mapping[lastColor]..mapping[lastColor]..mapping[lastColor]] = {} end
                                        drawCache["0x"..mapping[lastColor]..mapping[lastColor]..mapping[lastColor]][#drawCache["0x"..mapping[lastColor]..mapping[lastColor]..mapping[lastColor]]+1] = {renderChunkStart, textChunk}
                                        textChunk = {}
                                        renderChunkStart = i
                                        lastColor=c
                                    end

                                    
                                    if (idiff>1 or ydiff>0) then
                                        if not drawCache["0x"..mapping[lastColor]..mapping[lastColor]..mapping[lastColor]] then drawCache["0x"..mapping[lastColor]..mapping[lastColor]..mapping[lastColor]] = {} end
                                        drawCache["0x"..mapping[lastColor]..mapping[lastColor]..mapping[lastColor]][#drawCache["0x"..mapping[lastColor]..mapping[lastColor]..mapping[lastColor]]+1] = {renderChunkStart, textChunk}
                                        textChunk = {" "} 
                                        renderChunkStart = i
                                    else
                                        textChunk[#textChunk+1] = " "
                                    end
                                    lastY = y
                                    lastI = i
                                end
                            end
                            if #textChunk~=0 then
                                if not drawCache["0x"..mapping[lastColor]..mapping[lastColor]..mapping[lastColor]] then drawCache["0x"..mapping[lastColor]..mapping[lastColor]..mapping[lastColor]] = {} end
                                drawCache["0x"..mapping[lastColor]..mapping[lastColor]..mapping[lastColor]][#drawCache["0x"..mapping[lastColor]..mapping[lastColor]..mapping[lastColor]]+1] = {renderChunkStart, textChunk}
                            end
                            for i,v in pairs(drawCache) do
                                gpubackground(tonumber(i))
                                for chunkI=1,#v do
                                    local chunk = v[chunkI]
                                    local starty = mathfloor(chunk[1]/160)
                                    local startx = chunk[1]-(160*starty)
                                    gpuset(startx,starty+1,table.concat(chunk[2]))
                                end
                            end

                        end
                    end
                    print(uptime()-nextRun[currentF])
                    gpu.bitblt(0)
                
                    lastFrame = rawCurrent
                    rawCurrent = {}
                    currentFrame={}
                    currentFrameLengthCount=0
                end
            end
            for i,v in pairs(GPUCallList) do
                print(i,v)
            end
            print("Done! Peak Lag: "..tostring(peakLag).."s(+/-0.05)")
        end
    end
end

return module