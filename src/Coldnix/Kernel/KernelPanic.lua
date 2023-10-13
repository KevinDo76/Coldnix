--A custom "bluescreen" for the os
--could be usefull fatal crash debugging
function KernelPanic(err, tracebackErr)
    tracebackErr = tracebackErr or "no stack traceback:"
    --safe panic check
    if string.find(err,"Keyboard termination") then terminal.PanicReset(1) return end
    if string.find(err,"program termination, too long no yield") then computer.ElapseT=0 yieldCheck.start=computer.uptime() Log.writeLog("Program terminated, too long without yield") print(">>>Program terminated, too long without yield<<<") terminal.PanicReset(0) return end
    if err=="too long without yielding" then computer.ElapseT=0 yieldCheck.start=computer.uptime() Log.writeLog("Program terminated, too long without yield") print(">>>Program terminated, too long without yield<<<") terminal.PanicReset(0) return end
    --not safe beyond here
    err=err or "No error message provided"
    pcall(function() Log.writeLog("\nUnhandled error: "..err.."\nfatal error") end)
    --local variables
    local rx,ry=BOOTGPUPROXY.getResolution()
   

    local txtChunk={}
    local width=rx-6
    local startScrollCount = ry - 9
    local printEnded=false
    err="\nAN UNHANDLED ERROR HAS OCCURED\n \n"..tracebackErr.."\nend of stack traceback\n \nError Message: "..err.."\n \nSystem memory at crash: "..tostring(computer.freeMemory()/1024).."kb".."\nPress enter to restart\n  "
    --local functions

    local padText = function (txt,length)
        while (#txt<length) do
            txt=txt.." "
        end
        return txt
    end

    local function ewait(sec)
        local endTime=computer.uptime()+sec
        while computer.uptime()<endTime do
            local name, componentId,asciiNum,keyboardcode=computer.pullSignal(endTime-computer.uptime())
            if name=="key_down" and keyboardcode==28 and printEnded then
                BOOTGPUPROXY.fill(1,1,rx,ry," ")
                BOOTGPUPROXY.set(4,1,"restart in 1 second")
                local restartTime=computer.uptime()+1
                while computer.uptime()<restartTime do
                    computer.pullSignal(restartTime-computer.uptime())
                end
                computer.shutdown(true)
            end
        end
        return true
    end
    
    local function esplit(str,sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        str:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
    end
    --chopping up for \n and tab
    local Schunk=esplit(err,"\t")
    local rebuild=""
    if #Schunk>1 then
    for i,v in ipairs(Schunk) do
        rebuild=rebuild.."   "..v
    end
    err=rebuild
    end
    local txtChunk={}
    for i,v in ipairs(esplit(err,"\n")) do
       txtChunk[#txtChunk+1] = v
    end
    local finaChunk={}
    --toolong linebreak
    for i,v in ipairs(txtChunk) do
        repeat
            finaChunk[#finaChunk+1] = string.sub(v,1,width)
            v=string.sub(v,width+1,#v)
        until #v<1 
    end
    --screen clear
    if BOOTGPUPROXY.getDepth()>1 then
        BOOTGPUPROXY.setBackground(0x0000ff)
    else
        BOOTGPUPROXY.setBackground(0x000000)
    end
    
    BOOTGPUPROXY.setForeground(0xffffff)
    for i=1,ry do
        BOOTGPUPROXY.fill(1,1,rx,i," ") 
        ewait(0.01)
    end
    --draw sadface
    BOOTGPUPROXY.setForeground(0xffffff)
    BOOTGPUPROXY.setBackground(0xffffff)
    --eyes
    BOOTGPUPROXY.set(5,4,"#")
    BOOTGPUPROXY.set(4,4,"#")
    ewait(0.05)
    BOOTGPUPROXY.set(4,6,"#")
    BOOTGPUPROXY.set(5,6,"#")
    --mouth
    BOOTGPUPROXY.set(8,4,"#")
    BOOTGPUPROXY.set(9,4,"#")
    ewait(0.05)
    BOOTGPUPROXY.set(8,5,"#")
    BOOTGPUPROXY.set(9,5,"#")
    ewait(0.05)
    BOOTGPUPROXY.set(8,6,"#")
    BOOTGPUPROXY.set(9,6,"#")
    ewait(0.05)
    BOOTGPUPROXY.set(10,7,"#")
    BOOTGPUPROXY.set(11,7,"#")
    ewait(0.05)
    BOOTGPUPROXY.set(10,3,"#")
    BOOTGPUPROXY.set(11,3,"#")
    ewait(0.05)
    BOOTGPUPROXY.set(12,8,"#")
    BOOTGPUPROXY.set(13,8,"#")
    ewait(0.05)
    BOOTGPUPROXY.set(12,2,"#")
    BOOTGPUPROXY.set(13,2,"#")
    ewait(0.05)
    BOOTGPUPROXY.set(14,8,"#")
    BOOTGPUPROXY.set(15,8,"#")
    ewait(0.05)
    BOOTGPUPROXY.set(14,2,"#")
    BOOTGPUPROXY.set(15,2,"#")
    ewait(0.2)
    --outprint
    if BOOTGPUPROXY.getDepth()>1 then
        BOOTGPUPROXY.setBackground(0x0000ff)
    else
        BOOTGPUPROXY.setBackground(0x000000)
    end
    
    BOOTGPUPROXY.setForeground(0xffffff)
    for i,v in ipairs(finaChunk) do
        if i > startScrollCount then
            BOOTGPUPROXY.copy(1,2,rx ,ry,0,-1)
            BOOTGPUPROXY.set(0,ry,padText("",rx))
        end
        BOOTGPUPROXY.set(4,math.min(i+9,ry),padText(v,rx-4))
        ewait(0.1)
    end
    printEnded = true
    while true do
        ewait(0.05)
        computer.beep(1000,0.1)
    end
end



