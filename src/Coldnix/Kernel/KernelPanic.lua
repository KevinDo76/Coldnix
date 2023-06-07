--A custom "bluescreen" for the os
--could be usefull fatal crash debugging
function KernelPanic(err)
    if err=="Coldnix/Kernel/EventManager.lua:60: task termination" then print("Task terminated") return end
    err=err or "No error message provided"
    pcall(function() Log.writeLog("\nUnhandled error: "..err.."\nfatal error") end)
    --local variables
    local rx,ry=BOOTGPUPROXY.getResolution()
   

    local txtChunk={}
    local width=rx-6
    err="An unhandled error had occured\nError Message: "..err.."\n \nSystem Memory at crash: "..tostring(computer.freeMemory()/1024).."kb".."\nPress any key to restart"
    --local functions

    local function ewait(sec)
        local endTime=computer.uptime()+sec
        while computer.uptime()<endTime do
            local name=computer.pullSignal(endTime-computer.uptime())
            if name=="key_down" then
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
        ewait(0.1)
        BOOTGPUPROXY.set(4,i+9,v)
    end
    while true do
        ewait(0.05)
        computer.beep(1000,0.1)
    end
end



