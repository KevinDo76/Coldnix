--A custom "bluescreen" for the os
--could be usefull fatal crash debugging
function KernelPanic(err)
    pcall(function() Log.writeLog("\nUnhandled error: "..err.."\nfatal error") end)
    --local variables
    local rx,ry=BOOTGPUPROXY.getResolution()
    BOOTGPUPROXY.setBackground(0x000000)
    BOOTGPUPROXY.setForeground(0xffffff)
    BOOTGPUPROXY.fill(1,1,rx,ry," ")
    local txtChunk={}
    local width=rx-6
    err="An unhandled error had occured\nError Message: "..err.."\n \nPress any key to restart\nSystem Memory at crash: "..tostring(computer.freeMemory()/1024).."kb"
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
    --outprint
    for i,v in ipairs(finaChunk) do
        BOOTGPUPROXY.set(4,i,v)
    end
    while true do
        ewait(0.5)
        computer.beep(1000,0.1)
    end
end



